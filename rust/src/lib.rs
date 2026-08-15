//! Root library crate for the Sendme Rust backend.
//!
//! This crate provides high-performance peer-to-peer file sharing powered by Iroh
//! and exposes Flutter-friendly APIs via `flutter_rust_bridge`.

pub mod api;
mod frb_generated;

/// Initializes `ndk_context` on Android with a JNI Global Reference.
///
/// On Android, lower-level networking and system resolution crates (like `iroh`, `quinn`, and
/// DNS resolvers) require access to the Android `JVM` and `applicationContext`.
///
/// The `context` argument passed from Kotlin/Java is a local JNI reference valid only for
/// the lifetime of the native method call. This function promotes it to a JNI `GlobalRef`
/// and initializes `ndk_context`, ensuring it remains valid across all background threads
/// and asynchronous Tokio tasks for the lifetime of the application.
#[cfg(target_os = "android")]
#[no_mangle]
pub unsafe extern "C" fn Java_com_example_my_1app_MainActivity_initNdkContext(
    env: *mut jni::sys::JNIEnv,
    _class: jni::sys::jclass,
    context: jni::sys::jobject,
) {
    use std::sync::Once;
    static INIT: Once = Once::new();

    // Prevent any Rust panic from unwinding across the C FFI boundary.
    let _ = std::panic::catch_unwind(|| {
        if env.is_null() || context.is_null() {
            tracing::error!("initNdkContext called with null JNIEnv or jobject pointer");
            return;
        }

        INIT.call_once(|| {
            let env_obj = match unsafe { jni::JNIEnv::from_raw(env) } {
                Ok(e) => e,
                Err(err) => {
                    tracing::error!("Failed to wrap raw JNIEnv pointer: {err}");
                    return;
                }
            };

            let vm = match env_obj.get_java_vm() {
                Ok(v) => v,
                Err(err) => {
                    tracing::error!("Failed to obtain JavaVM from JNIEnv: {err}");
                    return;
                }
            };

            let vm_ptr = vm.get_java_vm_pointer() as *mut std::ffi::c_void;

            // Create a GlobalRef so the Android Application Context persists across all
            // threads and asynchronous callbacks.
            let local_obj = unsafe { jni::objects::JObject::from_raw(context) };
            match env_obj.new_global_ref(local_obj) {
                Ok(global_ref) => {
                    // Intentionally convert into a raw pointer so it is never dropped/freed
                    // during the application process lifecycle.
                    let global_context_raw = global_ref.into_raw();
                    let context_ptr = global_context_raw as *mut std::ffi::c_void;
                    unsafe {
                        ndk_context::initialize_android_context(vm_ptr, context_ptr);
                    }
                    tracing::info!("ndk_context initialized successfully with JNI GlobalRef");
                }
                Err(err) => {
                    tracing::error!("Failed to create JNI GlobalRef for ndk_context: {err}");
                }
            }
        });
    });
}
