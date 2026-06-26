"""
Jalankan skrip ini setiap hari (via Task Scheduler) untuk update data fashion.
Menjalankan notebook analisis dan mengekspor CSV.
"""
import subprocess, sys, os

NOTEBOOK_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'data', 'analisis_penjahit_shopee.ipynb')
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'data')

def run_notebook():
    """Eksekusi notebook dan export CSV."""
    # Jalankan notebook dengan jupyter nbconvert --execute
    cmd = [
        sys.executable, '-m', 'jupyter', 'nbconvert', '--to', 'notebook',
        '--execute', '--ExecutePreprocessor.timeout=120',
        '--output', os.path.join(OUTPUT_DIR, 'analisis_penjahit_shopee_executed.ipynb'),
        NOTEBOOK_PATH
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print('ERROR executing notebook:', result.stderr)
        return False
    print('Notebook executed OK')
    return True

if __name__ == '__main__':
    run_notebook()
    print('Daily update selesai.')
