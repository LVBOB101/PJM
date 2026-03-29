# Parking AI System

ระบบจัดการที่จอดรถอัจฉริยะที่ใช้ AI สำหรับตรวจจับและนับจำนวนรถในที่จอดรถแบบเรียลไทม์

## 🏗️ โครงสร้างโปรเจกต์

```
PJM/
├── backend/          # FastAPI Backend
│   ├── main.py       # Main API server
│   ├── database.py   # Database operations
│   ├── requirements.txt
│   ├── Dockerfile    # Docker configuration
│   └── yolov8n.pt    # AI Model
├── parking_web/      # Flutter Web Frontend
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
├── docker-compose.yml # Docker orchestration
├── HOWTO.txt         # คู่มือการใช้งาน
└── README.md         # เอกสารหลัก
```

## 📋 คุณสมบัติหลัก

- 🔐 **ระบบล็อกอิน/สมัครสมาชิก**: การจัดการผู้ใช้ที่ปลอดภัย
- 📹 **จัดการกล้อง**: เพิ่มและจัดการกล้อง CCTV RTSP
- 🎥 **ภาพสดจากกล้อง**: ดูภาพจากกล้องแบบเรียลไทม์พร้อม AI detection
- 🤖 **AI Detection**: ใช้ YOLOv8 สำหรับตรวจจับรถและวัตถุอื่นๆ
- 🌐 **WebRTC/WebSocket Streaming**: สตรีมมิ่งที่มี latency ต่ำ
- 📊 **แดชบอร์ด**: ดูรายการกล้องและสถานะการเชื่อมต่อ
- 🎨 **UI หรูหรา**: ออกแบบด้วย Material Design 3

## 🛠️ เทคโนโลยีที่ใช้

### Infrastructure
- **Docker**: Containerization
- **Docker Compose**: Container orchestration
- **PostgreSQL**: Database

### Frontend (Flutter Web)
- **Flutter**: Framework สำหรับพัฒนา UI
- **Dart**: ภาษาโปรแกรมมิ่ง
- **WebRTC/WebSocket**: สำหรับสตรีมมิ่งวิดีโอ
- **Material Design**: UI components

### Backend (FastAPI)
- **FastAPI**: Web framework ที่รวดเร็ว
- **OpenCV**: การประมวลผลภาพและวิดีโอ
- **Ultralytics YOLOv8**: AI สำหรับ object detection
- **PostgreSQL**: ฐานข้อมูล
- **RTSP**: โปรโตคอลสำหรับกล้อง CCTV

## 🚀 การติดตั้งและรัน

### ข้อกำหนดเบื้องต้น
- Docker Desktop
- Python 3.8+ (สำหรับพัฒนา)
- Flutter 3.0+ (สำหรับพัฒนา)
- Chrome browser (สำหรับ WebRTC)

### วิธีที่ 1: ใช้ Docker Compose (แนะนำ)

```bash
# รันทั้งระบบ (ฐานข้อมูล + Backend)
docker-compose up -d

# รัน Frontend แยก
cd parking_web
flutter pub get
flutter run -d chrome
```

### วิธีที่ 2: รันแยก (สำหรับพัฒนา)

#### 1. ตั้งค่าฐานข้อมูล
```bash
# รัน PostgreSQL ด้วย Docker
docker run --name parking-db \
  -e POSTGRES_PASSWORD=1234 \
  -e POSTGRES_DB=parking_db \
  -e POSTGRES_USER=postgres \
  -p 5432:5432 \
  -d postgres:13
```

#### 2. ติดตั้ง Backend
```bash
cd backend
pip install -r requirements.txt
python main.py
```

#### 3. ติดตั้ง Frontend
```bash
cd parking_web
flutter pub get
flutter run -d chrome
```

## 📱 หน้าจอของแอป

### 1. หน้าเข้าสู่ระบบ
- เข้าสู่ระบบด้วย username/password
- ลิงก์ไปหน้า สมัครสมาชิก

### 2. หน้ารายการกล้อง
- แสดงรายการกล้องทั้งหมด
- สถานะการเชื่อมต่อ
- ปุ่มเพิ่มกล้องใหม่
- ปุ่มออกจากระบบ

### 3. หน้าเพิ่มกล้อง
- ฟอร์มกรอกข้อมูลกล้อง (ชื่อ, IP, username, password)
- ทดสอบการเชื่อมต่อ
- ดูภาพตัวอย่าง

### 4. หน้าภาพสด
- ดูภาพจากกล้องแบบเรียลไทม์
- AI detection overlay
- สถานะการเชื่อมต่อ

## 🔌 API Endpoints

### Authentication
- `POST /login` - เข้าสู่ระบบ
- `POST /register` - สมัครสมาชิก

### Camera Management
- `GET /get_cameras` - ดูรายการกล้อง
- `POST /add_camera` - เพิ่มกล้องใหม่
- `POST /preview_camera` - ทดสอบการเชื่อมต่อกล้อง

### Streaming
- `POST /get_frame` - รับเฟรมภาพ (HTTP polling)
- `WebSocket /ws/live` - สตรีมมิ่งแบบเรียลไทม์
- `POST /offer` - WebRTC offer (สำหรับ mobile)

### System
- `GET /health` - เช็คสถานะระบบ

## 🎯 การใช้งาน

1. **เริ่มระบบ**: รัน backend และ frontend
2. **สมัครสมาชิก**: สร้างบัญชีผู้ใช้
3. **เข้าสู่ระบบ**: ล็อกอินด้วยข้อมูลที่สมัคร
4. **เพิ่มกล้อง**: กรอกข้อมูล RTSP ของกล้อง
5. **ดูภาพสด**: คลิกที่กล้องเพื่อดูภาพพร้อม AI detection

## 🔧 การปรับแต่ง

### AI Model
- เปลี่ยนโมเดล YOLO ใน `backend/main.py`
- ปรับ confidence threshold ในโค้ด

### UI Theme
- ปรับแต่งสีและธีมใน `parking_web/lib/main.dart`
- เพิ่มภาษาใน `parking_web/lib/screens/`

### Database
- ปรับแต่ง schema ใน `backend/database.py`
- เพิ่มฟีลด์ข้อมูลเพิ่มเติม

## 📈 Performance

- **Latency**: ~200-300ms สำหรับ WebSocket streaming
- **Frame Rate**: 2 FPS (ปรับได้ในโค้ด)
- **Resolution**: 640x360 (ปรับได้)
- **AI Processing**: YOLOv8n บน CPU

## 🐛 การแก้ปัญหา

### Backend ไม่รัน
- เช็ค Python version และ dependencies
- ตรวจสอบ PostgreSQL connection

### Frontend ไม่ build
- รัน `flutter clean` และ `flutter pub get`
- อัปเดต Flutter SDK

### กล้องไม่เชื่อมต่อ
- เช็ค RTSP URL และ credentials
- ตรวจสอบ firewall และ network

### WebRTC ไม่ทำงาน
- ใช้ HTTPS ใน production
- เช็ค browser compatibility

## 🤝 การมีส่วนร่วม

1. Fork โปรเจกต์
2. สร้าง feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit การเปลี่ยนแปลง (`git commit -m 'Add some AmazingFeature'`)
4. Push ไป branch (`git push origin feature/AmazingFeature`)
5. เปิด Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 👥 ผู้พัฒนา

- **Maeki** - *Initial work* - [GitHub](https://github.com/maeki)

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI Framework
- [FastAPI](https://fastapi.tiangolo.com/) - Web Framework
- [Ultralytics YOLO](https://github.com/ultralytics/ultralytics) - AI Model
- [OpenCV](https://opencv.org/) - Computer Vision
- [Material Design](https://material.io/) - Design System