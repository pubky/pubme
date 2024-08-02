use std::sync::{Arc, RwLock};

use once_cell::sync::Lazy;

use pkarr::{PkarrClient, PublicKey, Keypair};
 
 // There is a single "default" PubkyClient that can be shared
 // by all consumers of this component. Depending on requirements,
 // a real app might like to use a `Weak<>` rather than an `Arc<>`
 // here to reduce the risk of circular references.
 static DEFAULT_CLIENT: Lazy<RwLock<Option<Arc<PubkyClient>>>> = Lazy::new(|| RwLock::new(None));
 
 #[derive(Debug, thiserror::Error)]
 pub enum FfiError {
     #[error("Empty String error!: {0}")]
     RandomErrorDontCare(String),
 }

 #[derive(Debug, Clone)]
 pub struct FfiKeypair {
    public_key: String,
    private_key: String
 }
 
 /// Get a reference to the global default PubkyClient, if set.
 ///
 fn get_default_client() -> Option<Arc<PubkyClient>> {
     DEFAULT_CLIENT.read().unwrap().clone()
 }
 
 /// Set the global default PubkyClient.
 ///
 /// This will silently drop any previously set value.
 ///
 fn set_default_client(list: Arc<PubkyClient>) {
     *DEFAULT_CLIENT.write().unwrap() = Some(list);
 }
 
 type Result<T, E = FfiError> = std::result::Result<T, E>;
 
 static DEFAULT_USER_AGENT: &str = concat!(env!("CARGO_PKG_NAME"), "/", env!("CARGO_PKG_VERSION"),);

 // UniFFI requires that we use interior mutability for managing mutable state, so we wrap our `Vec` in a RwLock.
 // (A Mutex would also work, but a RwLock is more appropriate for this use-case, so we use it).
 #[derive(Debug)]
pub struct PubkyClient {
    http: reqwest::Client,
}
 
 impl PubkyClient {
     pub fn new() -> Self {
        Self {
            http: reqwest::Client::builder()
                .cookie_store(true)
                .user_agent(DEFAULT_USER_AGENT)
                .build()
                .unwrap(),
        }
    }

    pub fn pkarr_resolve(&self, public_key_str: String) -> Result<String> {
        let pkarr_client = PkarrClient::builder().build().unwrap();
        let public_key: PublicKey = public_key_str.try_into().expect("Invalid zbase32 encoded key");

        match pkarr_client.resolve(&public_key) {
            Ok(Some(signed_packet)) => Ok(format!("{}", signed_packet)),
            Ok(None) => Ok(format!("Failed to resolve {}", public_key)),
            Err(e) => Err(FfiError::RandomErrorDontCare(
                format!("Error resolving {}: {:?}", public_key, e),
            )),
        }           
    }

    pub fn signup(&self, keypair: FfiKeypair, homeserver: String) -> Result<()> {
        let public_key: PublicKey = keypair.public_key.try_into().expect("Invalid zbase32 encoded key");

        //TODO

        Ok(())
    }
 
     fn make_default(self: Arc<Self>) {
         set_default_client(self);
     }
 }
 
 uniffi::include_scaffolding!("pubky_client");