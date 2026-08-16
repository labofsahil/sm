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
/// # Safety
///
/// Must be called with valid JNI environment and context pointers by the Android JVM runtime.
#[cfg(target_os = "android")]
#[no_mangle]
pub unsafe extern "system" fn Java_com_example_my_1app_MainActivity_initNdkContext(
    mut unowned_env: jni::EnvUnowned,
    _this: jni::sys::jobject,
    context: jni::sys::jobject,
) {
    use std::sync::Once;
    static INIT: Once = Once::new();

    if context.is_null() {
        tracing::error!("initNdkContext called with null context pointer");
        return;
    }

    INIT.call_once(|| {
        let _ = unowned_env.with_env(|env| -> Result<(), jni::errors::Error> {
            let vm = match env.get_java_vm() {
                Ok(v) => v,
                Err(err) => {
                    tracing::error!("Failed to obtain JavaVM from JNIEnv: {err}");
                    return Ok(());
                }
            };

            let vm_ptr = vm.get_raw() as *mut std::ffi::c_void;

            // Create a GlobalRef so the Android Application Context persists across all
            // threads and asynchronous callbacks.
            let local_obj = unsafe { jni::objects::JObject::from_raw(env, context) };
            match env.new_global_ref(&local_obj) {
                Ok(global_ref) => {
                    // Obtain the raw jobject pointer from the GlobalRef and prevent deletion
                    // so it remains valid for the entire process lifetime.
                    let context_ptr = global_ref.into_raw() as *mut std::ffi::c_void;
                    unsafe {
                        ndk_context::initialize_android_context(vm_ptr, context_ptr);
                    }
                    tracing::info!("ndk_context initialized successfully with JNI GlobalRef");
                }
                Err(err) => {
                    tracing::error!("Failed to create JNI GlobalRef for ndk_context: {err}");
                }
            }
            Ok(())
        });
    });
}
