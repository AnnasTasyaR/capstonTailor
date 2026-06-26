Sistem Jahitln

IKUTI LANGKAH LANGKAH DI BAWAH AGAR APLIKASI BISA DIJALANKAN

Masukan file sql ke xammp, atau laragon, aku pake laragon, kalo kamu xammp juga ga papa
```bash
file sql di folder database
```

Masuk ke folder BackEnd
```bash
cd backend
```
```bash
flask run --debug
```

Daftar ngrok nya masuk ke website ngrok dan aktikan token nya
Contoh:
```bash
ngrok.com
```
```bash
ngrok config add-authtoken 3CiJdArSYnN8QJG3T4IlStILvqj_6GZysA2s3RAeoScYcZDGh
```
Sesuaikan portnya, cek di run.py apakah 5000? atau yang lain
```bash
ngrok http 5000
```

Kembali lagi ke folder flutter caranya :
```bash
cd ..
```
```bash
flutter pub get
```
```bash
flutter run
```
