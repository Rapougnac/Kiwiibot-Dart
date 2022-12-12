import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

final lib = DynamicLibrary.open('./libimages.so');

typedef IllegalFunc = IllegalReturn Function(Pointer<Utf8>, Pointer<Utf8>);

final IllegalFunc Illegal = lib.lookupFunction<IllegalFunc, IllegalFunc>('Illegal');

void main(List<String> args) {
  final that = illegal('illegal', 'Sex');
  File('out.gif').writeAsBytesSync(that);
}

Uint8List illegal(String dirToOpen, String text) {
  final dirToOpenPtr = dirToOpen.toNativeUtf8();
  final textPtr = text.toNativeUtf8();
  final res = Illegal(dirToOpenPtr, textPtr);
  malloc.free(dirToOpenPtr);
  malloc.free(textPtr);
  final data = res.r0.cast<Uint8>();
  final len = res.r1;
  final uint8ListData = data.asTypedList(len);
  malloc.free(data);

  return uint8ListData;
}

class IllegalReturn extends Struct {
  /// Data as a void* keeping uint_8 ref.
  external Pointer<Void> r0;

  /// Length of the buffer.
  @Int32()
  external int r1;
}
