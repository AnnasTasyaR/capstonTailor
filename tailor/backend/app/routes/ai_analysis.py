from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import get_jwt_identity
from app.middleware.jwt_guard import role_required
from PIL import Image, ImageFilter
import os, uuid, requests, json

ai_bp = Blueprint('ai', __name__)

@ai_bp.route('/api/ai/analyze', methods=['POST'])
@role_required('customer')
def analyze_design():
    if 'image' not in request.files:
        return jsonify({"msg": "Gambar harus diupload"}), 400
    file = request.files['image']
    if not file.filename:
        return jsonify({"msg": "File gambar kosong"}), 400

    # Save and process with Pillow
    ext = file.filename.rsplit('.', 1)[-1].lower() if '.' in file.filename else 'jpg'
    filename = f"analyze_{uuid.uuid4().hex}.{ext}"
    filepath = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    try:
        img = Image.open(filepath)
        img = img.resize((512, 512))
        img = img.convert('L')  # Grayscale
        img = img.filter(ImageFilter.SMOOTH)
        processed_path = filepath.replace(f'.{ext}', f'_processed.{ext}')
        img.save(processed_path)
    except Exception as e:
        return jsonify({"msg": f"Error processing image: {str(e)}"}), 500

    # Try Gemini API
    api_key = current_app.config.get('GEMINI_API_KEY', '')
    if api_key and api_key != 'your-gemini-api-key-here':
        try:
            import base64
            with open(processed_path, 'rb') as f:
                img_b64 = base64.b64encode(f.read()).decode()
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={api_key}"
            payload = {"contents":[{"parts":[
                {"text":"Analisis gambar desain pakaian ini. Tentukan tingkat kerumitan jahitan: SEDERHANA (jahitan lurus, potongan minimal), SEDANG (beberapa detail, jahitan variatif), atau RUMIT (banyak detail, bordir, lipit, potongan kompleks). Berikan estimasi waktu pengerjaan dalam hari. Respond in JSON format: {\"complexity\": \"sederhana/sedang/rumit\", \"estimated_days\": number}"},
                {"inline_data":{"mime_type":"image/jpeg","data":img_b64}}
            ]}]}
            resp = requests.post(url, json=payload, timeout=30)
            if resp.status_code == 200:
                text = resp.json()['candidates'][0]['content']['parts'][0]['text']
                text = text.strip()
                if text.startswith('```'): text = text.split('\n',1)[1].rsplit('```',1)[0]
                result = json.loads(text)
                return jsonify({"complexity": result.get("complexity","sedang"), "estimated_days": result.get("estimated_days",5), "image": filename}), 200
        except Exception:
            pass

    # Fallback: simple heuristic
    try:
        img = Image.open(filepath)
        w, h = img.size
        colors = len(set(list(img.convert('RGB').getdata())[:1000]))
        if colors < 50: c, d = 'sederhana', 3
        elif colors < 200: c, d = 'sedang', 5
        else: c, d = 'rumit', 10
    except:
        c, d = 'sedang', 5
    return jsonify({"complexity": c, "estimated_days": d, "image": filename}), 200
