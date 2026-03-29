import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';

class LiveViewScreen extends StatefulWidget {
  final String ip, user, pass, name;
  const LiveViewScreen({super.key, required this.ip, required this.user, required this.pass, required this.name});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  WebSocketChannel? _channel;
  Uint8List? _currentImage;
  bool _isConnected = false;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  String _serverUrl = 'ws://localhost:8000/ws/live';

  @override
  void initState() {
    super.initState();
    _initServerUrl();
    _connectWebSocket();
  }

  void _initServerUrl() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // For mobile, try to find the server IP
      try {
        var interfaces = await NetworkInterface.list();
        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 && !addr.address.startsWith('127.')) {
              // Assume the first non-loopback IPv4 is the server IP
              _serverUrl = 'ws://${addr.address}:8000/ws/live';
              break;
            }
          }
          if (!_serverUrl.contains('localhost')) break;
        }
      } catch (e) {
        print('Failed to get network interfaces: $e');
      }
    }
    print('Using server URL: $_serverUrl');
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_serverUrl),
      );

      // ส่ง camera data
      _channel!.sink.add(jsonEncode({
        'ip': widget.ip,
        'username': widget.user,
        'password': widget.pass,
      }));

      // รับ binary frames
      _channel!.stream.listen(
        (data) {
          if (data is Uint8List) {
            setState(() {
              _currentImage = data;
              _isConnected = true;
              _retryCount = 0;
            });
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleError();
        },
        onDone: () {
          print('WebSocket closed');
          _handleError();
        },
      );
    } catch (e) {
      print('WebSocket connect error: $e');
      _handleError();
    }
  }

  void _handleError() {
    _retryCount++;
    if (_retryCount >= _maxRetries && _isConnected) {
      setState(() => _isConnected = false);
    }
    // Retry after delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && _retryCount < _maxRetries) {
        _connectWebSocket();
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ภาพสด: ${widget.name}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: Theme.of(context).primaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'IP: ${widget.ip}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  child: _currentImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _currentImage!,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                _isConnected ? 'กำลังโหลดภาพ...' : 'รอการเชื่อมต่อ...',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    return _isConnected ? Colors.green : (_retryCount > 0 ? Colors.orange : Colors.grey);
  }

  String _getStatusText() {
    if (_isConnected) return 'เชื่อมต่อแล้ว';
    if (_retryCount > 0) return 'กำลังเชื่อมต่อ...';
    return 'กำลังโหลด...';
  }
}