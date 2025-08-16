import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'encryption_service.dart';

class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  final EncryptionService _encryptionService = EncryptionService();
  final List<AuditLog> _logs = [];
  late File _auditFile;
  
  // Configuración
  static const int MAX_LOGS_IN_MEMORY = 1000;
  static const int LOG_ROTATION_SIZE_MB = 10;

  // Inicializar servicio de auditoría
  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final auditDir = Directory('${directory.path}/audit');
    
    if (!await auditDir.exists()) {
      await auditDir.create(recursive: true);
    }
    
    _auditFile = File('${auditDir.path}/audit_${DateTime.now().millisecondsSinceEpoch}.log');
    await _loadExistingLogs();
  }

  // Registrar evento de auditoría
  Future<void> logEvent({
    required AuditEventType type,
    required String userId,
    required String action,
    Map<String, dynamic>? data,
    String? ipAddress,
    String? deviceId,
    AuditSeverity severity = AuditSeverity.info,
  }) async {
    final log = AuditLog(
      id: _generateLogId(),
      timestamp: DateTime.now(),
      type: type,
      userId: userId,
      action: action,
      data: data,
      ipAddress: ipAddress,
      deviceId: deviceId,
      severity: severity,
    );
    
    // Agregar a memoria
    _logs.add(log);
    
    // Escribir a archivo encriptado
    await _writeLogToFile(log);
    
    // Limpiar logs antiguos de memoria
    if (_logs.length > MAX_LOGS_IN_MEMORY) {
      _logs.removeRange(0, _logs.length - MAX_LOGS_IN_MEMORY);
    }
    
    // Verificar rotación de logs
    await _checkLogRotation();
    
    // Enviar logs críticos inmediatamente
    if (severity == AuditSeverity.critical) {
      await _sendCriticalLogToServer(log);
    }
  }

  // Escribir log a archivo
  Future<void> _writeLogToFile(AuditLog log) async {
    try {
      final logJson = log.toJson();
      final encryptedLog = _encryptionService.encryptJson(logJson);
      
      await _auditFile.writeAsString(
        '$encryptedLog\n',
        mode: FileMode.append,
      );
    } catch (e) {
      print('Error writing audit log: $e');
    }
  }

  // Verificar y rotar logs si es necesario
  Future<void> _checkLogRotation() async {
    final fileSize = await _auditFile.length();
    final sizeMB = fileSize / (1024 * 1024);
    
    if (sizeMB > LOG_ROTATION_SIZE_MB) {
      await _rotateLogFile();
    }
  }

  // Rotar archivo de log
  Future<void> _rotateLogFile() async {
    try {
      // Comprimir y enviar log antiguo
      await _compressAndUploadLog(_auditFile);
      
      // Crear nuevo archivo
      final directory = _auditFile.parent;
      _auditFile = File('${directory.path}/audit_${DateTime.now().millisecondsSinceEpoch}.log');
    } catch (e) {
      print('Error rotating log file: $e');
    }
  }

  // Comprimir y subir log
  Future<void> _compressAndUploadLog(File logFile) async {
    // Implementar compresión y upload a servidor/MCP
    print('Compressing and uploading log: ${logFile.path}');
  }

  // Cargar logs existentes
  Future<void> _loadExistingLogs() async {
    try {
      if (await _auditFile.exists()) {
        final lines = await _auditFile.readAsLines();
        
        for (final line in lines.take(MAX_LOGS_IN_MEMORY)) {
          try {
            final decryptedJson = _encryptionService.decryptJson(line);
            final log = AuditLog.fromJson(decryptedJson);
            _logs.add(log);
          } catch (e) {
            print('Error loading audit log: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading audit logs: $e');
    }
  }

  // Buscar logs
  Future<List<AuditLog>> searchLogs({
    String? userId,
    AuditEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    AuditSeverity? severity,
  }) async {
    return _logs.where((log) {
      if (userId != null && log.userId != userId) return false;
      if (type != null && log.type != type) return false;
      if (severity != null && log.severity != severity) return false;
      if (startDate != null && log.timestamp.isBefore(startDate)) return false;
      if (endDate != null && log.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  // Generar reporte de auditoría
  Future<Map<String, dynamic>> generateAuditReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final logs = await searchLogs(
      startDate: startDate,
      endDate: endDate,
    );
    
    final Map<String, dynamic> report = {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'totalEvents': logs.length,
      'eventsByType': <String, int>{},
      'eventsBySeverity': <String, int>{},
      'topUsers': <String, int>{},
      'criticalEvents': <Map<String, dynamic>>[],
    };
    
    for (final log in logs) {
      // Contar por tipo
      final typeKey = log.type.toString();
      final eventsByType = report['eventsByType'] as Map<String, int>;
      eventsByType[typeKey] = (eventsByType[typeKey] ?? 0) + 1;
      
      // Contar por severidad
      final severityKey = log.severity.toString();
      final eventsBySeverity = report['eventsBySeverity'] as Map<String, int>;
      eventsBySeverity[severityKey] = (eventsBySeverity[severityKey] ?? 0) + 1;
      
      // Contar por usuario
      final topUsers = report['topUsers'] as Map<String, int>;
      topUsers[log.userId] = (topUsers[log.userId] ?? 0) + 1;
      
      // Recopilar eventos críticos
      if (log.severity == AuditSeverity.critical) {
        (report['criticalEvents'] as List<Map<String, dynamic>>).add(log.toJson());
      }
    }
    
    return report;
  }

  // Enviar log crítico al servidor
  Future<void> _sendCriticalLogToServer(AuditLog log) async {
    // Implementar envío a MCP/N8N
    print('Sending critical log to server: ${log.toJson()}');
  }

  // Generar ID único para log
  String _generateLogId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_logs.length}';
  }

  // Limpiar logs antiguos
  Future<void> cleanupOldLogs({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    // Limpiar de memoria
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoffDate));
    
    // Limpiar archivos antiguos
    final directory = _auditFile.parent;
    final files = await directory.list().toList();
    
    for (final file in files) {
      if (file is File) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    }
  }

  // Exportar logs
  Future<String> exportLogs({
    required DateTime startDate,
    required DateTime endDate,
    required ExportFormat format,
  }) async {
    final logs = await searchLogs(
      startDate: startDate,
      endDate: endDate,
    );
    
    switch (format) {
      case ExportFormat.json:
        return json.encode(logs.map((l) => l.toJson()).toList());
      case ExportFormat.csv:
        return _convertToCSV(logs);
    }
  }

  // Convertir logs a CSV
  String _convertToCSV(List<AuditLog> logs) {
    final header = 'ID,Timestamp,Type,User,Action,Severity,Data\n';
    final rows = logs.map((log) {
      final data = json.encode(log.data ?? {});
      return '${log.id},${log.timestamp.toIso8601String()},${log.type},${log.userId},${log.action},${log.severity},"$data"';
    }).join('\n');
    
    return header + rows;
  }
}

// Modelos
class AuditLog {
  final String id;
  final DateTime timestamp;
  final AuditEventType type;
  final String userId;
  final String action;
  final Map<String, dynamic>? data;
  final String? ipAddress;
  final String? deviceId;
  final AuditSeverity severity;
  
  AuditLog({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.userId,
    required this.action,
    this.data,
    this.ipAddress,
    this.deviceId,
    required this.severity,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'type': type.toString(),
    'userId': userId,
    'action': action,
    'data': data,
    'ipAddress': ipAddress,
    'deviceId': deviceId,
    'severity': severity.toString(),
  };
  
  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    type: AuditEventType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    userId: json['userId'],
    action: json['action'],
    data: json['data'],
    ipAddress: json['ipAddress'],
    deviceId: json['deviceId'],
    severity: AuditSeverity.values.firstWhere(
      (e) => e.toString() == json['severity'],
    ),
  );
}

enum AuditEventType {
  login,
  logout,
  dataAccess,
  dataModification,
  paymentProcessed,
  securityEvent,
  configChange,
  userAction,
  systemEvent,
}

enum AuditSeverity {
  info,
  warning,
  error,
  critical,
}

enum ExportFormat {
  json,
  csv,
}