uniffi::setup_scaffolding!();
use pkarr::{PkarrClient, PublicKey};

#[uniffi::export]
fn resolve(public_key: String) -> String {
    let client = PkarrClient::builder().build().unwrap();

    let str: &str = &public_key;
    let public_key: PublicKey = str.try_into().expect("Invalid zbase32 encoded key");
    
    match client.resolve(&public_key) {
        Ok(Some(signed_packet)) => format!("{}", signed_packet),
        Ok(None) => format!("Failed to resolve {}", str),
        Err(e) => format!("Error resolving {}: {:?}", str, e),
    }
}
