// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sendme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReceiveProgress {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReceiveProgress()';
}


}

/// @nodoc
class $ReceiveProgressCopyWith<$Res>  {
$ReceiveProgressCopyWith(ReceiveProgress _, $Res Function(ReceiveProgress) __);
}


/// Adds pattern-matching-related methods to [ReceiveProgress].
extension ReceiveProgressPatterns on ReceiveProgress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ReceiveProgress_Connecting value)?  connecting,TResult Function( ReceiveProgress_Connected value)?  connected,TResult Function( ReceiveProgress_RetrievingMetadata value)?  retrievingMetadata,TResult Function( ReceiveProgress_Downloading value)?  downloading,TResult Function( ReceiveProgress_DownloadDone value)?  downloadDone,TResult Function( ReceiveProgress_Exporting value)?  exporting,TResult Function( ReceiveProgress_Finished value)?  finished,TResult Function( ReceiveProgress_Failed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ReceiveProgress_Connecting() when connecting != null:
return connecting(_that);case ReceiveProgress_Connected() when connected != null:
return connected(_that);case ReceiveProgress_RetrievingMetadata() when retrievingMetadata != null:
return retrievingMetadata(_that);case ReceiveProgress_Downloading() when downloading != null:
return downloading(_that);case ReceiveProgress_DownloadDone() when downloadDone != null:
return downloadDone(_that);case ReceiveProgress_Exporting() when exporting != null:
return exporting(_that);case ReceiveProgress_Finished() when finished != null:
return finished(_that);case ReceiveProgress_Failed() when failed != null:
return failed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ReceiveProgress_Connecting value)  connecting,required TResult Function( ReceiveProgress_Connected value)  connected,required TResult Function( ReceiveProgress_RetrievingMetadata value)  retrievingMetadata,required TResult Function( ReceiveProgress_Downloading value)  downloading,required TResult Function( ReceiveProgress_DownloadDone value)  downloadDone,required TResult Function( ReceiveProgress_Exporting value)  exporting,required TResult Function( ReceiveProgress_Finished value)  finished,required TResult Function( ReceiveProgress_Failed value)  failed,}){
final _that = this;
switch (_that) {
case ReceiveProgress_Connecting():
return connecting(_that);case ReceiveProgress_Connected():
return connected(_that);case ReceiveProgress_RetrievingMetadata():
return retrievingMetadata(_that);case ReceiveProgress_Downloading():
return downloading(_that);case ReceiveProgress_DownloadDone():
return downloadDone(_that);case ReceiveProgress_Exporting():
return exporting(_that);case ReceiveProgress_Finished():
return finished(_that);case ReceiveProgress_Failed():
return failed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ReceiveProgress_Connecting value)?  connecting,TResult? Function( ReceiveProgress_Connected value)?  connected,TResult? Function( ReceiveProgress_RetrievingMetadata value)?  retrievingMetadata,TResult? Function( ReceiveProgress_Downloading value)?  downloading,TResult? Function( ReceiveProgress_DownloadDone value)?  downloadDone,TResult? Function( ReceiveProgress_Exporting value)?  exporting,TResult? Function( ReceiveProgress_Finished value)?  finished,TResult? Function( ReceiveProgress_Failed value)?  failed,}){
final _that = this;
switch (_that) {
case ReceiveProgress_Connecting() when connecting != null:
return connecting(_that);case ReceiveProgress_Connected() when connected != null:
return connected(_that);case ReceiveProgress_RetrievingMetadata() when retrievingMetadata != null:
return retrievingMetadata(_that);case ReceiveProgress_Downloading() when downloading != null:
return downloading(_that);case ReceiveProgress_DownloadDone() when downloadDone != null:
return downloadDone(_that);case ReceiveProgress_Exporting() when exporting != null:
return exporting(_that);case ReceiveProgress_Finished() when finished != null:
return finished(_that);case ReceiveProgress_Failed() when failed != null:
return failed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  connecting,TResult Function()?  connected,TResult Function()?  retrievingMetadata,TResult Function( BigInt bytesDownloaded,  BigInt totalBytes,  double percentage)?  downloading,TResult Function( BigInt totalBytes)?  downloadDone,TResult Function( String fileName,  BigInt bytesExported,  BigInt bytesTotal)?  exporting,TResult Function( BigInt totalFiles,  BigInt totalBytes,  List<String> exportedPaths)?  finished,TResult Function( String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ReceiveProgress_Connecting() when connecting != null:
return connecting();case ReceiveProgress_Connected() when connected != null:
return connected();case ReceiveProgress_RetrievingMetadata() when retrievingMetadata != null:
return retrievingMetadata();case ReceiveProgress_Downloading() when downloading != null:
return downloading(_that.bytesDownloaded,_that.totalBytes,_that.percentage);case ReceiveProgress_DownloadDone() when downloadDone != null:
return downloadDone(_that.totalBytes);case ReceiveProgress_Exporting() when exporting != null:
return exporting(_that.fileName,_that.bytesExported,_that.bytesTotal);case ReceiveProgress_Finished() when finished != null:
return finished(_that.totalFiles,_that.totalBytes,_that.exportedPaths);case ReceiveProgress_Failed() when failed != null:
return failed(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  connecting,required TResult Function()  connected,required TResult Function()  retrievingMetadata,required TResult Function( BigInt bytesDownloaded,  BigInt totalBytes,  double percentage)  downloading,required TResult Function( BigInt totalBytes)  downloadDone,required TResult Function( String fileName,  BigInt bytesExported,  BigInt bytesTotal)  exporting,required TResult Function( BigInt totalFiles,  BigInt totalBytes,  List<String> exportedPaths)  finished,required TResult Function( String error)  failed,}) {final _that = this;
switch (_that) {
case ReceiveProgress_Connecting():
return connecting();case ReceiveProgress_Connected():
return connected();case ReceiveProgress_RetrievingMetadata():
return retrievingMetadata();case ReceiveProgress_Downloading():
return downloading(_that.bytesDownloaded,_that.totalBytes,_that.percentage);case ReceiveProgress_DownloadDone():
return downloadDone(_that.totalBytes);case ReceiveProgress_Exporting():
return exporting(_that.fileName,_that.bytesExported,_that.bytesTotal);case ReceiveProgress_Finished():
return finished(_that.totalFiles,_that.totalBytes,_that.exportedPaths);case ReceiveProgress_Failed():
return failed(_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  connecting,TResult? Function()?  connected,TResult? Function()?  retrievingMetadata,TResult? Function( BigInt bytesDownloaded,  BigInt totalBytes,  double percentage)?  downloading,TResult? Function( BigInt totalBytes)?  downloadDone,TResult? Function( String fileName,  BigInt bytesExported,  BigInt bytesTotal)?  exporting,TResult? Function( BigInt totalFiles,  BigInt totalBytes,  List<String> exportedPaths)?  finished,TResult? Function( String error)?  failed,}) {final _that = this;
switch (_that) {
case ReceiveProgress_Connecting() when connecting != null:
return connecting();case ReceiveProgress_Connected() when connected != null:
return connected();case ReceiveProgress_RetrievingMetadata() when retrievingMetadata != null:
return retrievingMetadata();case ReceiveProgress_Downloading() when downloading != null:
return downloading(_that.bytesDownloaded,_that.totalBytes,_that.percentage);case ReceiveProgress_DownloadDone() when downloadDone != null:
return downloadDone(_that.totalBytes);case ReceiveProgress_Exporting() when exporting != null:
return exporting(_that.fileName,_that.bytesExported,_that.bytesTotal);case ReceiveProgress_Finished() when finished != null:
return finished(_that.totalFiles,_that.totalBytes,_that.exportedPaths);case ReceiveProgress_Failed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ReceiveProgress_Connecting extends ReceiveProgress {
  const ReceiveProgress_Connecting(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_Connecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReceiveProgress.connecting()';
}


}




/// @nodoc


class ReceiveProgress_Connected extends ReceiveProgress {
  const ReceiveProgress_Connected(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_Connected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReceiveProgress.connected()';
}


}




/// @nodoc


class ReceiveProgress_RetrievingMetadata extends ReceiveProgress {
  const ReceiveProgress_RetrievingMetadata(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_RetrievingMetadata);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReceiveProgress.retrievingMetadata()';
}


}




/// @nodoc


class ReceiveProgress_Downloading extends ReceiveProgress {
  const ReceiveProgress_Downloading({required this.bytesDownloaded, required this.totalBytes, required this.percentage}): super._();
  

 final  BigInt bytesDownloaded;
 final  BigInt totalBytes;
 final  double percentage;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveProgress_DownloadingCopyWith<ReceiveProgress_Downloading> get copyWith => _$ReceiveProgress_DownloadingCopyWithImpl<ReceiveProgress_Downloading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_Downloading&&(identical(other.bytesDownloaded, bytesDownloaded) || other.bytesDownloaded == bytesDownloaded)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}


@override
int get hashCode => Object.hash(runtimeType,bytesDownloaded,totalBytes,percentage);

@override
String toString() {
  return 'ReceiveProgress.downloading(bytesDownloaded: $bytesDownloaded, totalBytes: $totalBytes, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class $ReceiveProgress_DownloadingCopyWith<$Res> implements $ReceiveProgressCopyWith<$Res> {
  factory $ReceiveProgress_DownloadingCopyWith(ReceiveProgress_Downloading value, $Res Function(ReceiveProgress_Downloading) _then) = _$ReceiveProgress_DownloadingCopyWithImpl;
@useResult
$Res call({
 BigInt bytesDownloaded, BigInt totalBytes, double percentage
});




}
/// @nodoc
class _$ReceiveProgress_DownloadingCopyWithImpl<$Res>
    implements $ReceiveProgress_DownloadingCopyWith<$Res> {
  _$ReceiveProgress_DownloadingCopyWithImpl(this._self, this._then);

  final ReceiveProgress_Downloading _self;
  final $Res Function(ReceiveProgress_Downloading) _then;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bytesDownloaded = null,Object? totalBytes = null,Object? percentage = null,}) {
  return _then(ReceiveProgress_Downloading(
bytesDownloaded: null == bytesDownloaded ? _self.bytesDownloaded : bytesDownloaded // ignore: cast_nullable_to_non_nullable
as BigInt,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as BigInt,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class ReceiveProgress_DownloadDone extends ReceiveProgress {
  const ReceiveProgress_DownloadDone({required this.totalBytes}): super._();
  

 final  BigInt totalBytes;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveProgress_DownloadDoneCopyWith<ReceiveProgress_DownloadDone> get copyWith => _$ReceiveProgress_DownloadDoneCopyWithImpl<ReceiveProgress_DownloadDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_DownloadDone&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes));
}


@override
int get hashCode => Object.hash(runtimeType,totalBytes);

@override
String toString() {
  return 'ReceiveProgress.downloadDone(totalBytes: $totalBytes)';
}


}

/// @nodoc
abstract mixin class $ReceiveProgress_DownloadDoneCopyWith<$Res> implements $ReceiveProgressCopyWith<$Res> {
  factory $ReceiveProgress_DownloadDoneCopyWith(ReceiveProgress_DownloadDone value, $Res Function(ReceiveProgress_DownloadDone) _then) = _$ReceiveProgress_DownloadDoneCopyWithImpl;
@useResult
$Res call({
 BigInt totalBytes
});




}
/// @nodoc
class _$ReceiveProgress_DownloadDoneCopyWithImpl<$Res>
    implements $ReceiveProgress_DownloadDoneCopyWith<$Res> {
  _$ReceiveProgress_DownloadDoneCopyWithImpl(this._self, this._then);

  final ReceiveProgress_DownloadDone _self;
  final $Res Function(ReceiveProgress_DownloadDone) _then;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? totalBytes = null,}) {
  return _then(ReceiveProgress_DownloadDone(
totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class ReceiveProgress_Exporting extends ReceiveProgress {
  const ReceiveProgress_Exporting({required this.fileName, required this.bytesExported, required this.bytesTotal}): super._();
  

 final  String fileName;
 final  BigInt bytesExported;
 final  BigInt bytesTotal;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveProgress_ExportingCopyWith<ReceiveProgress_Exporting> get copyWith => _$ReceiveProgress_ExportingCopyWithImpl<ReceiveProgress_Exporting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_Exporting&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.bytesExported, bytesExported) || other.bytesExported == bytesExported)&&(identical(other.bytesTotal, bytesTotal) || other.bytesTotal == bytesTotal));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,bytesExported,bytesTotal);

@override
String toString() {
  return 'ReceiveProgress.exporting(fileName: $fileName, bytesExported: $bytesExported, bytesTotal: $bytesTotal)';
}


}

/// @nodoc
abstract mixin class $ReceiveProgress_ExportingCopyWith<$Res> implements $ReceiveProgressCopyWith<$Res> {
  factory $ReceiveProgress_ExportingCopyWith(ReceiveProgress_Exporting value, $Res Function(ReceiveProgress_Exporting) _then) = _$ReceiveProgress_ExportingCopyWithImpl;
@useResult
$Res call({
 String fileName, BigInt bytesExported, BigInt bytesTotal
});




}
/// @nodoc
class _$ReceiveProgress_ExportingCopyWithImpl<$Res>
    implements $ReceiveProgress_ExportingCopyWith<$Res> {
  _$ReceiveProgress_ExportingCopyWithImpl(this._self, this._then);

  final ReceiveProgress_Exporting _self;
  final $Res Function(ReceiveProgress_Exporting) _then;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? bytesExported = null,Object? bytesTotal = null,}) {
  return _then(ReceiveProgress_Exporting(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,bytesExported: null == bytesExported ? _self.bytesExported : bytesExported // ignore: cast_nullable_to_non_nullable
as BigInt,bytesTotal: null == bytesTotal ? _self.bytesTotal : bytesTotal // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class ReceiveProgress_Finished extends ReceiveProgress {
  const ReceiveProgress_Finished({required this.totalFiles, required this.totalBytes, required final  List<String> exportedPaths}): _exportedPaths = exportedPaths,super._();
  

 final  BigInt totalFiles;
 final  BigInt totalBytes;
 final  List<String> _exportedPaths;
 List<String> get exportedPaths {
  if (_exportedPaths is EqualUnmodifiableListView) return _exportedPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exportedPaths);
}


/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveProgress_FinishedCopyWith<ReceiveProgress_Finished> get copyWith => _$ReceiveProgress_FinishedCopyWithImpl<ReceiveProgress_Finished>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_Finished&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&const DeepCollectionEquality().equals(other._exportedPaths, _exportedPaths));
}


@override
int get hashCode => Object.hash(runtimeType,totalFiles,totalBytes,const DeepCollectionEquality().hash(_exportedPaths));

@override
String toString() {
  return 'ReceiveProgress.finished(totalFiles: $totalFiles, totalBytes: $totalBytes, exportedPaths: $exportedPaths)';
}


}

/// @nodoc
abstract mixin class $ReceiveProgress_FinishedCopyWith<$Res> implements $ReceiveProgressCopyWith<$Res> {
  factory $ReceiveProgress_FinishedCopyWith(ReceiveProgress_Finished value, $Res Function(ReceiveProgress_Finished) _then) = _$ReceiveProgress_FinishedCopyWithImpl;
@useResult
$Res call({
 BigInt totalFiles, BigInt totalBytes, List<String> exportedPaths
});




}
/// @nodoc
class _$ReceiveProgress_FinishedCopyWithImpl<$Res>
    implements $ReceiveProgress_FinishedCopyWith<$Res> {
  _$ReceiveProgress_FinishedCopyWithImpl(this._self, this._then);

  final ReceiveProgress_Finished _self;
  final $Res Function(ReceiveProgress_Finished) _then;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? totalFiles = null,Object? totalBytes = null,Object? exportedPaths = null,}) {
  return _then(ReceiveProgress_Finished(
totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as BigInt,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as BigInt,exportedPaths: null == exportedPaths ? _self._exportedPaths : exportedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ReceiveProgress_Failed extends ReceiveProgress {
  const ReceiveProgress_Failed({required this.error}): super._();
  

 final  String error;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveProgress_FailedCopyWith<ReceiveProgress_Failed> get copyWith => _$ReceiveProgress_FailedCopyWithImpl<ReceiveProgress_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveProgress_Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ReceiveProgress.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $ReceiveProgress_FailedCopyWith<$Res> implements $ReceiveProgressCopyWith<$Res> {
  factory $ReceiveProgress_FailedCopyWith(ReceiveProgress_Failed value, $Res Function(ReceiveProgress_Failed) _then) = _$ReceiveProgress_FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$ReceiveProgress_FailedCopyWithImpl<$Res>
    implements $ReceiveProgress_FailedCopyWith<$Res> {
  _$ReceiveProgress_FailedCopyWithImpl(this._self, this._then);

  final ReceiveProgress_Failed _self;
  final $Res Function(ReceiveProgress_Failed) _then;

/// Create a copy of ReceiveProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ReceiveProgress_Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SendProgress {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendProgress);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SendProgress()';
}


}

/// @nodoc
class $SendProgressCopyWith<$Res>  {
$SendProgressCopyWith(SendProgress _, $Res Function(SendProgress) __);
}


/// Adds pattern-matching-related methods to [SendProgress].
extension SendProgressPatterns on SendProgress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SendProgress_Importing value)?  importing,TResult Function( SendProgress_ImportDone value)?  importDone,TResult Function( SendProgress_StartingEndpoint value)?  startingEndpoint,TResult Function( SendProgress_Sharing value)?  sharing,TResult Function( SendProgress_Failed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SendProgress_Importing() when importing != null:
return importing(_that);case SendProgress_ImportDone() when importDone != null:
return importDone(_that);case SendProgress_StartingEndpoint() when startingEndpoint != null:
return startingEndpoint(_that);case SendProgress_Sharing() when sharing != null:
return sharing(_that);case SendProgress_Failed() when failed != null:
return failed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SendProgress_Importing value)  importing,required TResult Function( SendProgress_ImportDone value)  importDone,required TResult Function( SendProgress_StartingEndpoint value)  startingEndpoint,required TResult Function( SendProgress_Sharing value)  sharing,required TResult Function( SendProgress_Failed value)  failed,}){
final _that = this;
switch (_that) {
case SendProgress_Importing():
return importing(_that);case SendProgress_ImportDone():
return importDone(_that);case SendProgress_StartingEndpoint():
return startingEndpoint(_that);case SendProgress_Sharing():
return sharing(_that);case SendProgress_Failed():
return failed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SendProgress_Importing value)?  importing,TResult? Function( SendProgress_ImportDone value)?  importDone,TResult? Function( SendProgress_StartingEndpoint value)?  startingEndpoint,TResult? Function( SendProgress_Sharing value)?  sharing,TResult? Function( SendProgress_Failed value)?  failed,}){
final _that = this;
switch (_that) {
case SendProgress_Importing() when importing != null:
return importing(_that);case SendProgress_ImportDone() when importDone != null:
return importDone(_that);case SendProgress_StartingEndpoint() when startingEndpoint != null:
return startingEndpoint(_that);case SendProgress_Sharing() when sharing != null:
return sharing(_that);case SendProgress_Failed() when failed != null:
return failed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String fileName,  BigInt bytesDone,  BigInt bytesTotal)?  importing,TResult Function( BigInt totalSize)?  importDone,TResult Function()?  startingEndpoint,TResult Function( String ticket)?  sharing,TResult Function( String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SendProgress_Importing() when importing != null:
return importing(_that.fileName,_that.bytesDone,_that.bytesTotal);case SendProgress_ImportDone() when importDone != null:
return importDone(_that.totalSize);case SendProgress_StartingEndpoint() when startingEndpoint != null:
return startingEndpoint();case SendProgress_Sharing() when sharing != null:
return sharing(_that.ticket);case SendProgress_Failed() when failed != null:
return failed(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String fileName,  BigInt bytesDone,  BigInt bytesTotal)  importing,required TResult Function( BigInt totalSize)  importDone,required TResult Function()  startingEndpoint,required TResult Function( String ticket)  sharing,required TResult Function( String error)  failed,}) {final _that = this;
switch (_that) {
case SendProgress_Importing():
return importing(_that.fileName,_that.bytesDone,_that.bytesTotal);case SendProgress_ImportDone():
return importDone(_that.totalSize);case SendProgress_StartingEndpoint():
return startingEndpoint();case SendProgress_Sharing():
return sharing(_that.ticket);case SendProgress_Failed():
return failed(_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String fileName,  BigInt bytesDone,  BigInt bytesTotal)?  importing,TResult? Function( BigInt totalSize)?  importDone,TResult? Function()?  startingEndpoint,TResult? Function( String ticket)?  sharing,TResult? Function( String error)?  failed,}) {final _that = this;
switch (_that) {
case SendProgress_Importing() when importing != null:
return importing(_that.fileName,_that.bytesDone,_that.bytesTotal);case SendProgress_ImportDone() when importDone != null:
return importDone(_that.totalSize);case SendProgress_StartingEndpoint() when startingEndpoint != null:
return startingEndpoint();case SendProgress_Sharing() when sharing != null:
return sharing(_that.ticket);case SendProgress_Failed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class SendProgress_Importing extends SendProgress {
  const SendProgress_Importing({required this.fileName, required this.bytesDone, required this.bytesTotal}): super._();
  

 final  String fileName;
 final  BigInt bytesDone;
 final  BigInt bytesTotal;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendProgress_ImportingCopyWith<SendProgress_Importing> get copyWith => _$SendProgress_ImportingCopyWithImpl<SendProgress_Importing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendProgress_Importing&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.bytesDone, bytesDone) || other.bytesDone == bytesDone)&&(identical(other.bytesTotal, bytesTotal) || other.bytesTotal == bytesTotal));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,bytesDone,bytesTotal);

@override
String toString() {
  return 'SendProgress.importing(fileName: $fileName, bytesDone: $bytesDone, bytesTotal: $bytesTotal)';
}


}

/// @nodoc
abstract mixin class $SendProgress_ImportingCopyWith<$Res> implements $SendProgressCopyWith<$Res> {
  factory $SendProgress_ImportingCopyWith(SendProgress_Importing value, $Res Function(SendProgress_Importing) _then) = _$SendProgress_ImportingCopyWithImpl;
@useResult
$Res call({
 String fileName, BigInt bytesDone, BigInt bytesTotal
});




}
/// @nodoc
class _$SendProgress_ImportingCopyWithImpl<$Res>
    implements $SendProgress_ImportingCopyWith<$Res> {
  _$SendProgress_ImportingCopyWithImpl(this._self, this._then);

  final SendProgress_Importing _self;
  final $Res Function(SendProgress_Importing) _then;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? bytesDone = null,Object? bytesTotal = null,}) {
  return _then(SendProgress_Importing(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,bytesDone: null == bytesDone ? _self.bytesDone : bytesDone // ignore: cast_nullable_to_non_nullable
as BigInt,bytesTotal: null == bytesTotal ? _self.bytesTotal : bytesTotal // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class SendProgress_ImportDone extends SendProgress {
  const SendProgress_ImportDone({required this.totalSize}): super._();
  

 final  BigInt totalSize;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendProgress_ImportDoneCopyWith<SendProgress_ImportDone> get copyWith => _$SendProgress_ImportDoneCopyWithImpl<SendProgress_ImportDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendProgress_ImportDone&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize));
}


@override
int get hashCode => Object.hash(runtimeType,totalSize);

@override
String toString() {
  return 'SendProgress.importDone(totalSize: $totalSize)';
}


}

/// @nodoc
abstract mixin class $SendProgress_ImportDoneCopyWith<$Res> implements $SendProgressCopyWith<$Res> {
  factory $SendProgress_ImportDoneCopyWith(SendProgress_ImportDone value, $Res Function(SendProgress_ImportDone) _then) = _$SendProgress_ImportDoneCopyWithImpl;
@useResult
$Res call({
 BigInt totalSize
});




}
/// @nodoc
class _$SendProgress_ImportDoneCopyWithImpl<$Res>
    implements $SendProgress_ImportDoneCopyWith<$Res> {
  _$SendProgress_ImportDoneCopyWithImpl(this._self, this._then);

  final SendProgress_ImportDone _self;
  final $Res Function(SendProgress_ImportDone) _then;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? totalSize = null,}) {
  return _then(SendProgress_ImportDone(
totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class SendProgress_StartingEndpoint extends SendProgress {
  const SendProgress_StartingEndpoint(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendProgress_StartingEndpoint);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SendProgress.startingEndpoint()';
}


}




/// @nodoc


class SendProgress_Sharing extends SendProgress {
  const SendProgress_Sharing({required this.ticket}): super._();
  

 final  String ticket;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendProgress_SharingCopyWith<SendProgress_Sharing> get copyWith => _$SendProgress_SharingCopyWithImpl<SendProgress_Sharing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendProgress_Sharing&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,ticket);

@override
String toString() {
  return 'SendProgress.sharing(ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class $SendProgress_SharingCopyWith<$Res> implements $SendProgressCopyWith<$Res> {
  factory $SendProgress_SharingCopyWith(SendProgress_Sharing value, $Res Function(SendProgress_Sharing) _then) = _$SendProgress_SharingCopyWithImpl;
@useResult
$Res call({
 String ticket
});




}
/// @nodoc
class _$SendProgress_SharingCopyWithImpl<$Res>
    implements $SendProgress_SharingCopyWith<$Res> {
  _$SendProgress_SharingCopyWithImpl(this._self, this._then);

  final SendProgress_Sharing _self;
  final $Res Function(SendProgress_Sharing) _then;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ticket = null,}) {
  return _then(SendProgress_Sharing(
ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SendProgress_Failed extends SendProgress {
  const SendProgress_Failed({required this.error}): super._();
  

 final  String error;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendProgress_FailedCopyWith<SendProgress_Failed> get copyWith => _$SendProgress_FailedCopyWithImpl<SendProgress_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendProgress_Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SendProgress.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $SendProgress_FailedCopyWith<$Res> implements $SendProgressCopyWith<$Res> {
  factory $SendProgress_FailedCopyWith(SendProgress_Failed value, $Res Function(SendProgress_Failed) _then) = _$SendProgress_FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$SendProgress_FailedCopyWithImpl<$Res>
    implements $SendProgress_FailedCopyWith<$Res> {
  _$SendProgress_FailedCopyWithImpl(this._self, this._then);

  final SendProgress_Failed _self;
  final $Res Function(SendProgress_Failed) _then;

/// Create a copy of SendProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(SendProgress_Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
