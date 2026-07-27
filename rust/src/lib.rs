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
        if let Ok(env) = unsafe { jni::JNIEnv::from_raw(env) } {
            if let Ok(vm) = env.get_java_vm() {
                let vm_ptr = vm.get_java_vm_pointer() as *mut std::ffi::c_void;
                let context_ptr = context as *mut std::ffi::c_void;
                unsafe {
                    ndk_context::initialize_android_context(vm_ptr, context_ptr);
                }
                tracing::info!("ndk_context initialized successfully via JNI");
            }
        }
    });
}

