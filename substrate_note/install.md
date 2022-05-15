## install



```bash
sudo apt update
# May prompt for location information
sudo apt install -y git clang curl libssl-dev llvm libudev-dev pkg-config
```

```bash
# Install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# Configure
source ~/.cargo/env
```



```bash
rustup default stable
rustup update
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly
```



[Glossary | Substrate_](https://docs.substrate.io/v3/getting-started/glossary/)

[Nominated Proof-of-Stake — Research at W3F (web3.foundation)](https://research.web3.foundation/en/latest/polkadot/NPoS/index.html)
