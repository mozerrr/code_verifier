import 'dart:developer';
import 'dart:isolate';
import 'package:quiver/core.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

class CodeVerifier {
  vm.VmService? _service;
  String? _isolateId;

  String? get _currentIsolateId {
    if (_isolateId != null) {
      return _isolateId;
    }
    _isolateId = Service.getIsolateID(Isolate.current);
    return _isolateId;
  }

  Future<vm.ScriptList> _getScripts() async {
    vm.VmService virtualMachine = await _getVMService();
    return virtualMachine.getScripts(_currentIsolateId!);
  }

  Future<vm.VmService> _getVMService() async {
    if (_service != null) {
      return Future.value(_service!);
    }
    ServiceProtocolInfo info = await Service.getInfo();
    String url = info.serverUri.toString();
    Uri uri = Uri.parse(url);
    Uri socketUri = convertToWebSocketUrl(serviceProtocolUrl: uri);
    _service = await vmServiceConnectUri(socketUri.toString());
    return _service!;
  }

  Future<int> codeHash() async {
    final ref = await _getScripts();
    final vmService = await _getVMService();
    final scriptsId = (ref.scripts ?? []).map((e) => e.id!);
    final scripts = <int>[];
    for (final id in scriptsId) {
      final script = await vmService.getObject(_currentIsolateId!, id) as vm.Script;
      final raw = script.source ?? '';
      final hash = hashObjects(raw.codeUnits);
      scripts.add(hash);
    }

    return hashObjects(scripts);
  }
}
