uniffi::setup_scaffolding!();

#[derive(Debug, Eq, PartialEq, uniffi::Record)]
pub struct CoreInfo {
    pub name: String,
    pub version: String,
}

#[uniffi::export]
pub fn core_info() -> CoreInfo {
    CoreInfo {
        name: "Lupka".to_owned(),
        version: env!("CARGO_PKG_VERSION").to_owned(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn core_info_matches_the_package() {
        assert_eq!(
            core_info(),
            CoreInfo {
                name: "Lupka".to_owned(),
                version: env!("CARGO_PKG_VERSION").to_owned(),
            }
        );
    }
}
