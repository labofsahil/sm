// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sendme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReceiveProgress {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiveProgressCopyWith<$Res> {
  factory $ReceiveProgressCopyWith(
    ReceiveProgress value,
    $Res Function(ReceiveProgress) then,
  ) = _$ReceiveProgressCopyWithImpl<$Res, ReceiveProgress>;
}

/// @nodoc
class _$ReceiveProgressCopyWithImpl<$Res, $Val extends ReceiveProgress>
    implements $ReceiveProgressCopyWith<$Res> {
  _$ReceiveProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ReceiveProgress_ConnectingImplCopyWith<$Res> {
  factory _$$ReceiveProgress_ConnectingImplCopyWith(
    _$ReceiveProgress_ConnectingImpl value,
    $Res Function(_$ReceiveProgress_ConnectingImpl) then,
  ) = __$$ReceiveProgress_ConnectingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ReceiveProgress_ConnectingImplCopyWithImpl<$Res>
    extends
        _$ReceiveProgressCopyWithImpl<$Res, _$ReceiveProgress_ConnectingImpl>
    implements _$$ReceiveProgress_ConnectingImplCopyWith<$Res> {
  __$$ReceiveProgress_ConnectingImplCopyWithImpl(
    _$ReceiveProgress_ConnectingImpl _value,
    $Res Function(_$ReceiveProgress_ConnectingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ReceiveProgress_ConnectingImpl extends ReceiveProgress_Connecting {
  const _$ReceiveProgress_ConnectingImpl() : super._();

  @override
  String toString() {
    return 'ReceiveProgress.connecting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_ConnectingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return connecting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return connecting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return connecting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return connecting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_Connecting extends ReceiveProgress {
  const factory ReceiveProgress_Connecting() = _$ReceiveProgress_ConnectingImpl;
  const ReceiveProgress_Connecting._() : super._();
}

/// @nodoc
abstract class _$$ReceiveProgress_ConnectedImplCopyWith<$Res> {
  factory _$$ReceiveProgress_ConnectedImplCopyWith(
    _$ReceiveProgress_ConnectedImpl value,
    $Res Function(_$ReceiveProgress_ConnectedImpl) then,
  ) = __$$ReceiveProgress_ConnectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ReceiveProgress_ConnectedImplCopyWithImpl<$Res>
    extends _$ReceiveProgressCopyWithImpl<$Res, _$ReceiveProgress_ConnectedImpl>
    implements _$$ReceiveProgress_ConnectedImplCopyWith<$Res> {
  __$$ReceiveProgress_ConnectedImplCopyWithImpl(
    _$ReceiveProgress_ConnectedImpl _value,
    $Res Function(_$ReceiveProgress_ConnectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ReceiveProgress_ConnectedImpl extends ReceiveProgress_Connected {
  const _$ReceiveProgress_ConnectedImpl() : super._();

  @override
  String toString() {
    return 'ReceiveProgress.connected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_ConnectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return connected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return connected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return connected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return connected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_Connected extends ReceiveProgress {
  const factory ReceiveProgress_Connected() = _$ReceiveProgress_ConnectedImpl;
  const ReceiveProgress_Connected._() : super._();
}

/// @nodoc
abstract class _$$ReceiveProgress_RetrievingMetadataImplCopyWith<$Res> {
  factory _$$ReceiveProgress_RetrievingMetadataImplCopyWith(
    _$ReceiveProgress_RetrievingMetadataImpl value,
    $Res Function(_$ReceiveProgress_RetrievingMetadataImpl) then,
  ) = __$$ReceiveProgress_RetrievingMetadataImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ReceiveProgress_RetrievingMetadataImplCopyWithImpl<$Res>
    extends
        _$ReceiveProgressCopyWithImpl<
          $Res,
          _$ReceiveProgress_RetrievingMetadataImpl
        >
    implements _$$ReceiveProgress_RetrievingMetadataImplCopyWith<$Res> {
  __$$ReceiveProgress_RetrievingMetadataImplCopyWithImpl(
    _$ReceiveProgress_RetrievingMetadataImpl _value,
    $Res Function(_$ReceiveProgress_RetrievingMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ReceiveProgress_RetrievingMetadataImpl
    extends ReceiveProgress_RetrievingMetadata {
  const _$ReceiveProgress_RetrievingMetadataImpl() : super._();

  @override
  String toString() {
    return 'ReceiveProgress.retrievingMetadata()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_RetrievingMetadataImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return retrievingMetadata();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return retrievingMetadata?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (retrievingMetadata != null) {
      return retrievingMetadata();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return retrievingMetadata(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return retrievingMetadata?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (retrievingMetadata != null) {
      return retrievingMetadata(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_RetrievingMetadata extends ReceiveProgress {
  const factory ReceiveProgress_RetrievingMetadata() =
      _$ReceiveProgress_RetrievingMetadataImpl;
  const ReceiveProgress_RetrievingMetadata._() : super._();
}

/// @nodoc
abstract class _$$ReceiveProgress_DownloadingImplCopyWith<$Res> {
  factory _$$ReceiveProgress_DownloadingImplCopyWith(
    _$ReceiveProgress_DownloadingImpl value,
    $Res Function(_$ReceiveProgress_DownloadingImpl) then,
  ) = __$$ReceiveProgress_DownloadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt bytesDownloaded, BigInt totalBytes, double percentage});
}

/// @nodoc
class __$$ReceiveProgress_DownloadingImplCopyWithImpl<$Res>
    extends
        _$ReceiveProgressCopyWithImpl<$Res, _$ReceiveProgress_DownloadingImpl>
    implements _$$ReceiveProgress_DownloadingImplCopyWith<$Res> {
  __$$ReceiveProgress_DownloadingImplCopyWithImpl(
    _$ReceiveProgress_DownloadingImpl _value,
    $Res Function(_$ReceiveProgress_DownloadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bytesDownloaded = null,
    Object? totalBytes = null,
    Object? percentage = null,
  }) {
    return _then(
      _$ReceiveProgress_DownloadingImpl(
        bytesDownloaded: null == bytesDownloaded
            ? _value.bytesDownloaded
            : bytesDownloaded // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$ReceiveProgress_DownloadingImpl extends ReceiveProgress_Downloading {
  const _$ReceiveProgress_DownloadingImpl({
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.percentage,
  }) : super._();

  @override
  final BigInt bytesDownloaded;
  @override
  final BigInt totalBytes;
  @override
  final double percentage;

  @override
  String toString() {
    return 'ReceiveProgress.downloading(bytesDownloaded: $bytesDownloaded, totalBytes: $totalBytes, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_DownloadingImpl &&
            (identical(other.bytesDownloaded, bytesDownloaded) ||
                other.bytesDownloaded == bytesDownloaded) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, bytesDownloaded, totalBytes, percentage);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiveProgress_DownloadingImplCopyWith<_$ReceiveProgress_DownloadingImpl>
  get copyWith =>
      __$$ReceiveProgress_DownloadingImplCopyWithImpl<
        _$ReceiveProgress_DownloadingImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return downloading(bytesDownloaded, totalBytes, percentage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return downloading?.call(bytesDownloaded, totalBytes, percentage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(bytesDownloaded, totalBytes, percentage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return downloading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return downloading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_Downloading extends ReceiveProgress {
  const factory ReceiveProgress_Downloading({
    required final BigInt bytesDownloaded,
    required final BigInt totalBytes,
    required final double percentage,
  }) = _$ReceiveProgress_DownloadingImpl;
  const ReceiveProgress_Downloading._() : super._();

  BigInt get bytesDownloaded;
  BigInt get totalBytes;
  double get percentage;

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiveProgress_DownloadingImplCopyWith<_$ReceiveProgress_DownloadingImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReceiveProgress_DownloadDoneImplCopyWith<$Res> {
  factory _$$ReceiveProgress_DownloadDoneImplCopyWith(
    _$ReceiveProgress_DownloadDoneImpl value,
    $Res Function(_$ReceiveProgress_DownloadDoneImpl) then,
  ) = __$$ReceiveProgress_DownloadDoneImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt totalBytes});
}

/// @nodoc
class __$$ReceiveProgress_DownloadDoneImplCopyWithImpl<$Res>
    extends
        _$ReceiveProgressCopyWithImpl<$Res, _$ReceiveProgress_DownloadDoneImpl>
    implements _$$ReceiveProgress_DownloadDoneImplCopyWith<$Res> {
  __$$ReceiveProgress_DownloadDoneImplCopyWithImpl(
    _$ReceiveProgress_DownloadDoneImpl _value,
    $Res Function(_$ReceiveProgress_DownloadDoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? totalBytes = null}) {
    return _then(
      _$ReceiveProgress_DownloadDoneImpl(
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$ReceiveProgress_DownloadDoneImpl extends ReceiveProgress_DownloadDone {
  const _$ReceiveProgress_DownloadDoneImpl({required this.totalBytes})
    : super._();

  @override
  final BigInt totalBytes;

  @override
  String toString() {
    return 'ReceiveProgress.downloadDone(totalBytes: $totalBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_DownloadDoneImpl &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalBytes);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiveProgress_DownloadDoneImplCopyWith<
    _$ReceiveProgress_DownloadDoneImpl
  >
  get copyWith =>
      __$$ReceiveProgress_DownloadDoneImplCopyWithImpl<
        _$ReceiveProgress_DownloadDoneImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return downloadDone(totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return downloadDone?.call(totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (downloadDone != null) {
      return downloadDone(totalBytes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return downloadDone(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return downloadDone?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (downloadDone != null) {
      return downloadDone(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_DownloadDone extends ReceiveProgress {
  const factory ReceiveProgress_DownloadDone({
    required final BigInt totalBytes,
  }) = _$ReceiveProgress_DownloadDoneImpl;
  const ReceiveProgress_DownloadDone._() : super._();

  BigInt get totalBytes;

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiveProgress_DownloadDoneImplCopyWith<
    _$ReceiveProgress_DownloadDoneImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReceiveProgress_ExportingImplCopyWith<$Res> {
  factory _$$ReceiveProgress_ExportingImplCopyWith(
    _$ReceiveProgress_ExportingImpl value,
    $Res Function(_$ReceiveProgress_ExportingImpl) then,
  ) = __$$ReceiveProgress_ExportingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String fileName, BigInt bytesExported, BigInt bytesTotal});
}

/// @nodoc
class __$$ReceiveProgress_ExportingImplCopyWithImpl<$Res>
    extends _$ReceiveProgressCopyWithImpl<$Res, _$ReceiveProgress_ExportingImpl>
    implements _$$ReceiveProgress_ExportingImplCopyWith<$Res> {
  __$$ReceiveProgress_ExportingImplCopyWithImpl(
    _$ReceiveProgress_ExportingImpl _value,
    $Res Function(_$ReceiveProgress_ExportingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? bytesExported = null,
    Object? bytesTotal = null,
  }) {
    return _then(
      _$ReceiveProgress_ExportingImpl(
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        bytesExported: null == bytesExported
            ? _value.bytesExported
            : bytesExported // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        bytesTotal: null == bytesTotal
            ? _value.bytesTotal
            : bytesTotal // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$ReceiveProgress_ExportingImpl extends ReceiveProgress_Exporting {
  const _$ReceiveProgress_ExportingImpl({
    required this.fileName,
    required this.bytesExported,
    required this.bytesTotal,
  }) : super._();

  @override
  final String fileName;
  @override
  final BigInt bytesExported;
  @override
  final BigInt bytesTotal;

  @override
  String toString() {
    return 'ReceiveProgress.exporting(fileName: $fileName, bytesExported: $bytesExported, bytesTotal: $bytesTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_ExportingImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.bytesExported, bytesExported) ||
                other.bytesExported == bytesExported) &&
            (identical(other.bytesTotal, bytesTotal) ||
                other.bytesTotal == bytesTotal));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, fileName, bytesExported, bytesTotal);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiveProgress_ExportingImplCopyWith<_$ReceiveProgress_ExportingImpl>
  get copyWith =>
      __$$ReceiveProgress_ExportingImplCopyWithImpl<
        _$ReceiveProgress_ExportingImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return exporting(fileName, bytesExported, bytesTotal);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return exporting?.call(fileName, bytesExported, bytesTotal);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (exporting != null) {
      return exporting(fileName, bytesExported, bytesTotal);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return exporting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return exporting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (exporting != null) {
      return exporting(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_Exporting extends ReceiveProgress {
  const factory ReceiveProgress_Exporting({
    required final String fileName,
    required final BigInt bytesExported,
    required final BigInt bytesTotal,
  }) = _$ReceiveProgress_ExportingImpl;
  const ReceiveProgress_Exporting._() : super._();

  String get fileName;
  BigInt get bytesExported;
  BigInt get bytesTotal;

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiveProgress_ExportingImplCopyWith<_$ReceiveProgress_ExportingImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReceiveProgress_FinishedImplCopyWith<$Res> {
  factory _$$ReceiveProgress_FinishedImplCopyWith(
    _$ReceiveProgress_FinishedImpl value,
    $Res Function(_$ReceiveProgress_FinishedImpl) then,
  ) = __$$ReceiveProgress_FinishedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt totalFiles, BigInt totalBytes});
}

/// @nodoc
class __$$ReceiveProgress_FinishedImplCopyWithImpl<$Res>
    extends _$ReceiveProgressCopyWithImpl<$Res, _$ReceiveProgress_FinishedImpl>
    implements _$$ReceiveProgress_FinishedImplCopyWith<$Res> {
  __$$ReceiveProgress_FinishedImplCopyWithImpl(
    _$ReceiveProgress_FinishedImpl _value,
    $Res Function(_$ReceiveProgress_FinishedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? totalFiles = null, Object? totalBytes = null}) {
    return _then(
      _$ReceiveProgress_FinishedImpl(
        totalFiles: null == totalFiles
            ? _value.totalFiles
            : totalFiles // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$ReceiveProgress_FinishedImpl extends ReceiveProgress_Finished {
  const _$ReceiveProgress_FinishedImpl({
    required this.totalFiles,
    required this.totalBytes,
  }) : super._();

  @override
  final BigInt totalFiles;
  @override
  final BigInt totalBytes;

  @override
  String toString() {
    return 'ReceiveProgress.finished(totalFiles: $totalFiles, totalBytes: $totalBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_FinishedImpl &&
            (identical(other.totalFiles, totalFiles) ||
                other.totalFiles == totalFiles) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalFiles, totalBytes);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiveProgress_FinishedImplCopyWith<_$ReceiveProgress_FinishedImpl>
  get copyWith =>
      __$$ReceiveProgress_FinishedImplCopyWithImpl<
        _$ReceiveProgress_FinishedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return finished(totalFiles, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return finished?.call(totalFiles, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (finished != null) {
      return finished(totalFiles, totalBytes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return finished(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return finished?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (finished != null) {
      return finished(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_Finished extends ReceiveProgress {
  const factory ReceiveProgress_Finished({
    required final BigInt totalFiles,
    required final BigInt totalBytes,
  }) = _$ReceiveProgress_FinishedImpl;
  const ReceiveProgress_Finished._() : super._();

  BigInt get totalFiles;
  BigInt get totalBytes;

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiveProgress_FinishedImplCopyWith<_$ReceiveProgress_FinishedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReceiveProgress_FailedImplCopyWith<$Res> {
  factory _$$ReceiveProgress_FailedImplCopyWith(
    _$ReceiveProgress_FailedImpl value,
    $Res Function(_$ReceiveProgress_FailedImpl) then,
  ) = __$$ReceiveProgress_FailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$ReceiveProgress_FailedImplCopyWithImpl<$Res>
    extends _$ReceiveProgressCopyWithImpl<$Res, _$ReceiveProgress_FailedImpl>
    implements _$$ReceiveProgress_FailedImplCopyWith<$Res> {
  __$$ReceiveProgress_FailedImplCopyWithImpl(
    _$ReceiveProgress_FailedImpl _value,
    $Res Function(_$ReceiveProgress_FailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? error = null}) {
    return _then(
      _$ReceiveProgress_FailedImpl(
        error: null == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ReceiveProgress_FailedImpl extends ReceiveProgress_Failed {
  const _$ReceiveProgress_FailedImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'ReceiveProgress.failed(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveProgress_FailedImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiveProgress_FailedImplCopyWith<_$ReceiveProgress_FailedImpl>
  get copyWith =>
      __$$ReceiveProgress_FailedImplCopyWithImpl<_$ReceiveProgress_FailedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connecting,
    required TResult Function() connected,
    required TResult Function() retrievingMetadata,
    required TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )
    downloading,
    required TResult Function(BigInt totalBytes) downloadDone,
    required TResult Function(
      String fileName,
      BigInt bytesExported,
      BigInt bytesTotal,
    )
    exporting,
    required TResult Function(BigInt totalFiles, BigInt totalBytes) finished,
    required TResult Function(String error) failed,
  }) {
    return failed(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connecting,
    TResult? Function()? connected,
    TResult? Function()? retrievingMetadata,
    TResult? Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult? Function(BigInt totalBytes)? downloadDone,
    TResult? Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult? Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult? Function(String error)? failed,
  }) {
    return failed?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connecting,
    TResult Function()? connected,
    TResult Function()? retrievingMetadata,
    TResult Function(
      BigInt bytesDownloaded,
      BigInt totalBytes,
      double percentage,
    )?
    downloading,
    TResult Function(BigInt totalBytes)? downloadDone,
    TResult Function(String fileName, BigInt bytesExported, BigInt bytesTotal)?
    exporting,
    TResult Function(BigInt totalFiles, BigInt totalBytes)? finished,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReceiveProgress_Connecting value) connecting,
    required TResult Function(ReceiveProgress_Connected value) connected,
    required TResult Function(ReceiveProgress_RetrievingMetadata value)
    retrievingMetadata,
    required TResult Function(ReceiveProgress_Downloading value) downloading,
    required TResult Function(ReceiveProgress_DownloadDone value) downloadDone,
    required TResult Function(ReceiveProgress_Exporting value) exporting,
    required TResult Function(ReceiveProgress_Finished value) finished,
    required TResult Function(ReceiveProgress_Failed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReceiveProgress_Connecting value)? connecting,
    TResult? Function(ReceiveProgress_Connected value)? connected,
    TResult? Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult? Function(ReceiveProgress_Downloading value)? downloading,
    TResult? Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult? Function(ReceiveProgress_Exporting value)? exporting,
    TResult? Function(ReceiveProgress_Finished value)? finished,
    TResult? Function(ReceiveProgress_Failed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReceiveProgress_Connecting value)? connecting,
    TResult Function(ReceiveProgress_Connected value)? connected,
    TResult Function(ReceiveProgress_RetrievingMetadata value)?
    retrievingMetadata,
    TResult Function(ReceiveProgress_Downloading value)? downloading,
    TResult Function(ReceiveProgress_DownloadDone value)? downloadDone,
    TResult Function(ReceiveProgress_Exporting value)? exporting,
    TResult Function(ReceiveProgress_Finished value)? finished,
    TResult Function(ReceiveProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class ReceiveProgress_Failed extends ReceiveProgress {
  const factory ReceiveProgress_Failed({required final String error}) =
      _$ReceiveProgress_FailedImpl;
  const ReceiveProgress_Failed._() : super._();

  String get error;

  /// Create a copy of ReceiveProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiveProgress_FailedImplCopyWith<_$ReceiveProgress_FailedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SendProgress {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fileName,
      BigInt bytesDone,
      BigInt bytesTotal,
    )
    importing,
    required TResult Function(BigInt totalSize) importDone,
    required TResult Function() startingEndpoint,
    required TResult Function(String ticket) sharing,
    required TResult Function(String error) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult? Function(BigInt totalSize)? importDone,
    TResult? Function()? startingEndpoint,
    TResult? Function(String ticket)? sharing,
    TResult? Function(String error)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult Function(BigInt totalSize)? importDone,
    TResult Function()? startingEndpoint,
    TResult Function(String ticket)? sharing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SendProgress_Importing value) importing,
    required TResult Function(SendProgress_ImportDone value) importDone,
    required TResult Function(SendProgress_StartingEndpoint value)
    startingEndpoint,
    required TResult Function(SendProgress_Sharing value) sharing,
    required TResult Function(SendProgress_Failed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SendProgress_Importing value)? importing,
    TResult? Function(SendProgress_ImportDone value)? importDone,
    TResult? Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult? Function(SendProgress_Sharing value)? sharing,
    TResult? Function(SendProgress_Failed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SendProgress_Importing value)? importing,
    TResult Function(SendProgress_ImportDone value)? importDone,
    TResult Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult Function(SendProgress_Sharing value)? sharing,
    TResult Function(SendProgress_Failed value)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendProgressCopyWith<$Res> {
  factory $SendProgressCopyWith(
    SendProgress value,
    $Res Function(SendProgress) then,
  ) = _$SendProgressCopyWithImpl<$Res, SendProgress>;
}

/// @nodoc
class _$SendProgressCopyWithImpl<$Res, $Val extends SendProgress>
    implements $SendProgressCopyWith<$Res> {
  _$SendProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SendProgress_ImportingImplCopyWith<$Res> {
  factory _$$SendProgress_ImportingImplCopyWith(
    _$SendProgress_ImportingImpl value,
    $Res Function(_$SendProgress_ImportingImpl) then,
  ) = __$$SendProgress_ImportingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String fileName, BigInt bytesDone, BigInt bytesTotal});
}

/// @nodoc
class __$$SendProgress_ImportingImplCopyWithImpl<$Res>
    extends _$SendProgressCopyWithImpl<$Res, _$SendProgress_ImportingImpl>
    implements _$$SendProgress_ImportingImplCopyWith<$Res> {
  __$$SendProgress_ImportingImplCopyWithImpl(
    _$SendProgress_ImportingImpl _value,
    $Res Function(_$SendProgress_ImportingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? bytesDone = null,
    Object? bytesTotal = null,
  }) {
    return _then(
      _$SendProgress_ImportingImpl(
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        bytesDone: null == bytesDone
            ? _value.bytesDone
            : bytesDone // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        bytesTotal: null == bytesTotal
            ? _value.bytesTotal
            : bytesTotal // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$SendProgress_ImportingImpl extends SendProgress_Importing {
  const _$SendProgress_ImportingImpl({
    required this.fileName,
    required this.bytesDone,
    required this.bytesTotal,
  }) : super._();

  @override
  final String fileName;
  @override
  final BigInt bytesDone;
  @override
  final BigInt bytesTotal;

  @override
  String toString() {
    return 'SendProgress.importing(fileName: $fileName, bytesDone: $bytesDone, bytesTotal: $bytesTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendProgress_ImportingImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.bytesDone, bytesDone) ||
                other.bytesDone == bytesDone) &&
            (identical(other.bytesTotal, bytesTotal) ||
                other.bytesTotal == bytesTotal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fileName, bytesDone, bytesTotal);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendProgress_ImportingImplCopyWith<_$SendProgress_ImportingImpl>
  get copyWith =>
      __$$SendProgress_ImportingImplCopyWithImpl<_$SendProgress_ImportingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fileName,
      BigInt bytesDone,
      BigInt bytesTotal,
    )
    importing,
    required TResult Function(BigInt totalSize) importDone,
    required TResult Function() startingEndpoint,
    required TResult Function(String ticket) sharing,
    required TResult Function(String error) failed,
  }) {
    return importing(fileName, bytesDone, bytesTotal);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult? Function(BigInt totalSize)? importDone,
    TResult? Function()? startingEndpoint,
    TResult? Function(String ticket)? sharing,
    TResult? Function(String error)? failed,
  }) {
    return importing?.call(fileName, bytesDone, bytesTotal);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult Function(BigInt totalSize)? importDone,
    TResult Function()? startingEndpoint,
    TResult Function(String ticket)? sharing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (importing != null) {
      return importing(fileName, bytesDone, bytesTotal);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SendProgress_Importing value) importing,
    required TResult Function(SendProgress_ImportDone value) importDone,
    required TResult Function(SendProgress_StartingEndpoint value)
    startingEndpoint,
    required TResult Function(SendProgress_Sharing value) sharing,
    required TResult Function(SendProgress_Failed value) failed,
  }) {
    return importing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SendProgress_Importing value)? importing,
    TResult? Function(SendProgress_ImportDone value)? importDone,
    TResult? Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult? Function(SendProgress_Sharing value)? sharing,
    TResult? Function(SendProgress_Failed value)? failed,
  }) {
    return importing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SendProgress_Importing value)? importing,
    TResult Function(SendProgress_ImportDone value)? importDone,
    TResult Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult Function(SendProgress_Sharing value)? sharing,
    TResult Function(SendProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (importing != null) {
      return importing(this);
    }
    return orElse();
  }
}

abstract class SendProgress_Importing extends SendProgress {
  const factory SendProgress_Importing({
    required final String fileName,
    required final BigInt bytesDone,
    required final BigInt bytesTotal,
  }) = _$SendProgress_ImportingImpl;
  const SendProgress_Importing._() : super._();

  String get fileName;
  BigInt get bytesDone;
  BigInt get bytesTotal;

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendProgress_ImportingImplCopyWith<_$SendProgress_ImportingImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SendProgress_ImportDoneImplCopyWith<$Res> {
  factory _$$SendProgress_ImportDoneImplCopyWith(
    _$SendProgress_ImportDoneImpl value,
    $Res Function(_$SendProgress_ImportDoneImpl) then,
  ) = __$$SendProgress_ImportDoneImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt totalSize});
}

/// @nodoc
class __$$SendProgress_ImportDoneImplCopyWithImpl<$Res>
    extends _$SendProgressCopyWithImpl<$Res, _$SendProgress_ImportDoneImpl>
    implements _$$SendProgress_ImportDoneImplCopyWith<$Res> {
  __$$SendProgress_ImportDoneImplCopyWithImpl(
    _$SendProgress_ImportDoneImpl _value,
    $Res Function(_$SendProgress_ImportDoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? totalSize = null}) {
    return _then(
      _$SendProgress_ImportDoneImpl(
        totalSize: null == totalSize
            ? _value.totalSize
            : totalSize // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$SendProgress_ImportDoneImpl extends SendProgress_ImportDone {
  const _$SendProgress_ImportDoneImpl({required this.totalSize}) : super._();

  @override
  final BigInt totalSize;

  @override
  String toString() {
    return 'SendProgress.importDone(totalSize: $totalSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendProgress_ImportDoneImpl &&
            (identical(other.totalSize, totalSize) ||
                other.totalSize == totalSize));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalSize);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendProgress_ImportDoneImplCopyWith<_$SendProgress_ImportDoneImpl>
  get copyWith =>
      __$$SendProgress_ImportDoneImplCopyWithImpl<
        _$SendProgress_ImportDoneImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fileName,
      BigInt bytesDone,
      BigInt bytesTotal,
    )
    importing,
    required TResult Function(BigInt totalSize) importDone,
    required TResult Function() startingEndpoint,
    required TResult Function(String ticket) sharing,
    required TResult Function(String error) failed,
  }) {
    return importDone(totalSize);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult? Function(BigInt totalSize)? importDone,
    TResult? Function()? startingEndpoint,
    TResult? Function(String ticket)? sharing,
    TResult? Function(String error)? failed,
  }) {
    return importDone?.call(totalSize);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult Function(BigInt totalSize)? importDone,
    TResult Function()? startingEndpoint,
    TResult Function(String ticket)? sharing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (importDone != null) {
      return importDone(totalSize);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SendProgress_Importing value) importing,
    required TResult Function(SendProgress_ImportDone value) importDone,
    required TResult Function(SendProgress_StartingEndpoint value)
    startingEndpoint,
    required TResult Function(SendProgress_Sharing value) sharing,
    required TResult Function(SendProgress_Failed value) failed,
  }) {
    return importDone(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SendProgress_Importing value)? importing,
    TResult? Function(SendProgress_ImportDone value)? importDone,
    TResult? Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult? Function(SendProgress_Sharing value)? sharing,
    TResult? Function(SendProgress_Failed value)? failed,
  }) {
    return importDone?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SendProgress_Importing value)? importing,
    TResult Function(SendProgress_ImportDone value)? importDone,
    TResult Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult Function(SendProgress_Sharing value)? sharing,
    TResult Function(SendProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (importDone != null) {
      return importDone(this);
    }
    return orElse();
  }
}

abstract class SendProgress_ImportDone extends SendProgress {
  const factory SendProgress_ImportDone({required final BigInt totalSize}) =
      _$SendProgress_ImportDoneImpl;
  const SendProgress_ImportDone._() : super._();

  BigInt get totalSize;

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendProgress_ImportDoneImplCopyWith<_$SendProgress_ImportDoneImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SendProgress_StartingEndpointImplCopyWith<$Res> {
  factory _$$SendProgress_StartingEndpointImplCopyWith(
    _$SendProgress_StartingEndpointImpl value,
    $Res Function(_$SendProgress_StartingEndpointImpl) then,
  ) = __$$SendProgress_StartingEndpointImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SendProgress_StartingEndpointImplCopyWithImpl<$Res>
    extends
        _$SendProgressCopyWithImpl<$Res, _$SendProgress_StartingEndpointImpl>
    implements _$$SendProgress_StartingEndpointImplCopyWith<$Res> {
  __$$SendProgress_StartingEndpointImplCopyWithImpl(
    _$SendProgress_StartingEndpointImpl _value,
    $Res Function(_$SendProgress_StartingEndpointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SendProgress_StartingEndpointImpl
    extends SendProgress_StartingEndpoint {
  const _$SendProgress_StartingEndpointImpl() : super._();

  @override
  String toString() {
    return 'SendProgress.startingEndpoint()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendProgress_StartingEndpointImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fileName,
      BigInt bytesDone,
      BigInt bytesTotal,
    )
    importing,
    required TResult Function(BigInt totalSize) importDone,
    required TResult Function() startingEndpoint,
    required TResult Function(String ticket) sharing,
    required TResult Function(String error) failed,
  }) {
    return startingEndpoint();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult? Function(BigInt totalSize)? importDone,
    TResult? Function()? startingEndpoint,
    TResult? Function(String ticket)? sharing,
    TResult? Function(String error)? failed,
  }) {
    return startingEndpoint?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult Function(BigInt totalSize)? importDone,
    TResult Function()? startingEndpoint,
    TResult Function(String ticket)? sharing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (startingEndpoint != null) {
      return startingEndpoint();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SendProgress_Importing value) importing,
    required TResult Function(SendProgress_ImportDone value) importDone,
    required TResult Function(SendProgress_StartingEndpoint value)
    startingEndpoint,
    required TResult Function(SendProgress_Sharing value) sharing,
    required TResult Function(SendProgress_Failed value) failed,
  }) {
    return startingEndpoint(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SendProgress_Importing value)? importing,
    TResult? Function(SendProgress_ImportDone value)? importDone,
    TResult? Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult? Function(SendProgress_Sharing value)? sharing,
    TResult? Function(SendProgress_Failed value)? failed,
  }) {
    return startingEndpoint?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SendProgress_Importing value)? importing,
    TResult Function(SendProgress_ImportDone value)? importDone,
    TResult Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult Function(SendProgress_Sharing value)? sharing,
    TResult Function(SendProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (startingEndpoint != null) {
      return startingEndpoint(this);
    }
    return orElse();
  }
}

abstract class SendProgress_StartingEndpoint extends SendProgress {
  const factory SendProgress_StartingEndpoint() =
      _$SendProgress_StartingEndpointImpl;
  const SendProgress_StartingEndpoint._() : super._();
}

/// @nodoc
abstract class _$$SendProgress_SharingImplCopyWith<$Res> {
  factory _$$SendProgress_SharingImplCopyWith(
    _$SendProgress_SharingImpl value,
    $Res Function(_$SendProgress_SharingImpl) then,
  ) = __$$SendProgress_SharingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String ticket});
}

/// @nodoc
class __$$SendProgress_SharingImplCopyWithImpl<$Res>
    extends _$SendProgressCopyWithImpl<$Res, _$SendProgress_SharingImpl>
    implements _$$SendProgress_SharingImplCopyWith<$Res> {
  __$$SendProgress_SharingImplCopyWithImpl(
    _$SendProgress_SharingImpl _value,
    $Res Function(_$SendProgress_SharingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? ticket = null}) {
    return _then(
      _$SendProgress_SharingImpl(
        ticket: null == ticket
            ? _value.ticket
            : ticket // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SendProgress_SharingImpl extends SendProgress_Sharing {
  const _$SendProgress_SharingImpl({required this.ticket}) : super._();

  @override
  final String ticket;

  @override
  String toString() {
    return 'SendProgress.sharing(ticket: $ticket)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendProgress_SharingImpl &&
            (identical(other.ticket, ticket) || other.ticket == ticket));
  }

  @override
  int get hashCode => Object.hash(runtimeType, ticket);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendProgress_SharingImplCopyWith<_$SendProgress_SharingImpl>
  get copyWith =>
      __$$SendProgress_SharingImplCopyWithImpl<_$SendProgress_SharingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fileName,
      BigInt bytesDone,
      BigInt bytesTotal,
    )
    importing,
    required TResult Function(BigInt totalSize) importDone,
    required TResult Function() startingEndpoint,
    required TResult Function(String ticket) sharing,
    required TResult Function(String error) failed,
  }) {
    return sharing(ticket);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult? Function(BigInt totalSize)? importDone,
    TResult? Function()? startingEndpoint,
    TResult? Function(String ticket)? sharing,
    TResult? Function(String error)? failed,
  }) {
    return sharing?.call(ticket);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult Function(BigInt totalSize)? importDone,
    TResult Function()? startingEndpoint,
    TResult Function(String ticket)? sharing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (sharing != null) {
      return sharing(ticket);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SendProgress_Importing value) importing,
    required TResult Function(SendProgress_ImportDone value) importDone,
    required TResult Function(SendProgress_StartingEndpoint value)
    startingEndpoint,
    required TResult Function(SendProgress_Sharing value) sharing,
    required TResult Function(SendProgress_Failed value) failed,
  }) {
    return sharing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SendProgress_Importing value)? importing,
    TResult? Function(SendProgress_ImportDone value)? importDone,
    TResult? Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult? Function(SendProgress_Sharing value)? sharing,
    TResult? Function(SendProgress_Failed value)? failed,
  }) {
    return sharing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SendProgress_Importing value)? importing,
    TResult Function(SendProgress_ImportDone value)? importDone,
    TResult Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult Function(SendProgress_Sharing value)? sharing,
    TResult Function(SendProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (sharing != null) {
      return sharing(this);
    }
    return orElse();
  }
}

abstract class SendProgress_Sharing extends SendProgress {
  const factory SendProgress_Sharing({required final String ticket}) =
      _$SendProgress_SharingImpl;
  const SendProgress_Sharing._() : super._();

  String get ticket;

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendProgress_SharingImplCopyWith<_$SendProgress_SharingImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SendProgress_FailedImplCopyWith<$Res> {
  factory _$$SendProgress_FailedImplCopyWith(
    _$SendProgress_FailedImpl value,
    $Res Function(_$SendProgress_FailedImpl) then,
  ) = __$$SendProgress_FailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$SendProgress_FailedImplCopyWithImpl<$Res>
    extends _$SendProgressCopyWithImpl<$Res, _$SendProgress_FailedImpl>
    implements _$$SendProgress_FailedImplCopyWith<$Res> {
  __$$SendProgress_FailedImplCopyWithImpl(
    _$SendProgress_FailedImpl _value,
    $Res Function(_$SendProgress_FailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? error = null}) {
    return _then(
      _$SendProgress_FailedImpl(
        error: null == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SendProgress_FailedImpl extends SendProgress_Failed {
  const _$SendProgress_FailedImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'SendProgress.failed(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendProgress_FailedImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendProgress_FailedImplCopyWith<_$SendProgress_FailedImpl> get copyWith =>
      __$$SendProgress_FailedImplCopyWithImpl<_$SendProgress_FailedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fileName,
      BigInt bytesDone,
      BigInt bytesTotal,
    )
    importing,
    required TResult Function(BigInt totalSize) importDone,
    required TResult Function() startingEndpoint,
    required TResult Function(String ticket) sharing,
    required TResult Function(String error) failed,
  }) {
    return failed(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult? Function(BigInt totalSize)? importDone,
    TResult? Function()? startingEndpoint,
    TResult? Function(String ticket)? sharing,
    TResult? Function(String error)? failed,
  }) {
    return failed?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String fileName, BigInt bytesDone, BigInt bytesTotal)?
    importing,
    TResult Function(BigInt totalSize)? importDone,
    TResult Function()? startingEndpoint,
    TResult Function(String ticket)? sharing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SendProgress_Importing value) importing,
    required TResult Function(SendProgress_ImportDone value) importDone,
    required TResult Function(SendProgress_StartingEndpoint value)
    startingEndpoint,
    required TResult Function(SendProgress_Sharing value) sharing,
    required TResult Function(SendProgress_Failed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SendProgress_Importing value)? importing,
    TResult? Function(SendProgress_ImportDone value)? importDone,
    TResult? Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult? Function(SendProgress_Sharing value)? sharing,
    TResult? Function(SendProgress_Failed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SendProgress_Importing value)? importing,
    TResult Function(SendProgress_ImportDone value)? importDone,
    TResult Function(SendProgress_StartingEndpoint value)? startingEndpoint,
    TResult Function(SendProgress_Sharing value)? sharing,
    TResult Function(SendProgress_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class SendProgress_Failed extends SendProgress {
  const factory SendProgress_Failed({required final String error}) =
      _$SendProgress_FailedImpl;
  const SendProgress_Failed._() : super._();

  String get error;

  /// Create a copy of SendProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendProgress_FailedImplCopyWith<_$SendProgress_FailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
