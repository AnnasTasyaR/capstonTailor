import smtplib, os, random, string
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta

SMTP_HOST = os.environ.get('SMTP_HOST', 'smtp.gmail.com')
SMTP_PORT = int(os.environ.get('SMTP_PORT', 587))
SMTP_USER = os.environ.get('SMTP_USER', '')
SMTP_PASS = os.environ.get('SMTP_PASS', '')
FROM_EMAIL = os.environ.get('FROM_EMAIL', 'noreply@tailorlink.id')


def generate_code(length: int = 6) -> str:
    return ''.join(random.choices(string.digits, k=length))


def send_verification_email(to_email: str, code: str) -> bool:
    if not SMTP_USER or not SMTP_PASS:
        print(f'[DEV MODE] Verification code for {to_email}: {code}')
        return True

    subject = 'Kode Verifikasi Email - Jahitln'
    body = f"""
    <html>
    <body style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Jahitln - Verifikasi Email</h2>
        <p>Gunakan kode berikut untuk memverifikasi email Anda:</p>
        <h1 style="font-size: 32px; letter-spacing: 6px; color: #1B2A6B;">{code}</h1>
        <p>Kode ini berlaku selama 5 menit.</p>
        <p>Jika Anda tidak meminta kode ini, abaikan email ini.</p>
        <br>
        <p>Tim Jahitln</p>
    </body>
    </html>
    """

    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = FROM_EMAIL
    msg['To'] = to_email
    msg.attach(MIMEText(body, 'html'))

    try:
        server = smtplib.SMTP(SMTP_HOST, SMTP_PORT)
        server.starttls()
        server.login(SMTP_USER, SMTP_PASS)
        server.send_message(msg)
        server.quit()
        return True
    except Exception as e:
        print(f'Email send error: {e}')
        return False
