pub mod api;
mod frb_generated;

#[cfg(target_os = "android")]
#[no_mangle]
pub unsafe extern "C" fn Java_com_example_my_1app_MainActivity_initNdkContext(
    env: *mut jni::sys::JNIEnv,
    _class: jni::sys::jclass,
    context: jni::sys::jobject,
) {
    use std::sync::Once;
    static INIT: Once = Once::new();

    INIT.call_once(|| {
        if let Ok(env_obj) = unsafe { jni::JNIEnv::from_raw(env) } {
            if let Ok(vm) = env_obj.get_java_vm() {
                let vm_ptr = vm.get_java_vm_pointer() as *mut std::ffi::c_void;
                // The `context` passed in is a JNI local reference that is only valid
                // for the duration of this call. ndk_context requires a global reference
                // that persists across all threads and asynchronous callbacks.
                let global_context = unsafe {
                    let jni_native = *env;
                    if let Some(new_global_ref) = (*jni_native).NewGlobalRef {
                        new_global_ref(env, context)
                    } else {
                        std::ptr::null_mut()
                    }
                };

                if !global_context.is_null() {
                    let context_ptr = global_context as *mut std::ffi::c_void;
                    unsafe {
                        ndk_context::initialize_android_context(vm_ptr, context_ptr);
                    }
                    tracing::info!("ndk_context initialized successfully via JNI with GlobalRef");
                } else {
                    tracing::error!("Failed to create NewGlobalRef for ndk_context");
                }
            }
        }
    });
}


