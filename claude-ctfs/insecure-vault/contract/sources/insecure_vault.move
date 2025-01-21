module insecure_vault_addr::insecure_vault {
    use std::signer;
    use std::vector;
    use aptos_std::table::{Self, Table};
    use aptos_framework::coin::{Self, Coin, BurnCapability, MintCapability};

    // Struct to represent a user's vault
    struct Vault has key {
        balances: Table<address, u64>,
        total_deposits: u64,
        admin: address
    }

    // Capability for minting and burning custom tokens
    struct VaultTokenCapabilities has key {
        mint_cap: MintCapability<VaultToken>,
        burn_cap: BurnCapability<VaultToken>
    }

    // Custom token for the vault
    struct VaultToken {}

    // Error codes
    const E_NOT_ADMIN: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const E_DEPOSIT_OVERFLOW: u64 = 3;

    // Initialize the vault module with admin capabilities
    public fun initialize(admin: &signer) {
        let admin_addr = signer::address_of(admin);

        // Create vault for the admin
        if (!exists<Vault>(admin_addr)) {
            move_to(admin, Vault {
                balances: table::new(),
                total_deposits: 0,
                admin: admin_addr
            });
        };

        // Initialize token capabilities
        if (!exists<VaultTokenCapabilities>(admin_addr)) {
            let (mint_cap, burn_cap) = coin::initialize<VaultToken>(
                admin,
                std::string::utf8(b"VaultToken"),
                std::string::utf8(b"VT"),
                9,
                true
            );

            move_to(admin, VaultTokenCapabilities {
                mint_cap,
                burn_cap
            });
        }
    }

    // Deposit function
    public entry fun deposit(depositor: &signer, amount: u64) acquires Vault {
        let depositor_addr = signer::address_of(depositor);

        let vault = borrow_global_mut<Vault>(@vulnerabilities);
        vault.total_deposits = vault.total_deposits + amount;

        if (!table::contains(&vault.balances, depositor_addr)) {
            table::add(&mut vault.balances, depositor_addr, amount);
        } else {
            let current_balance = table::borrow_mut(&mut vault.balances, depositor_addr);
            *current_balance = *current_balance + amount;
        }
    }

    // Withdraw function
    public entry fun withdraw(withdrawer: &signer, amount: u64) acquires Vault {
        let withdrawer_addr = signer::address_of(withdrawer);
        let vault = borrow_global_mut<Vault>(@vulnerabilities);

        if (table::contains(&vault.balances, withdrawer_addr)) {
            let balance = table::borrow_mut(&mut vault.balances, withdrawer_addr);

            *balance = *balance - amount;
            vault.total_deposits = vault.total_deposits - amount;
        }
    }

    // Admin-only token minting function
    public entry fun mint_tokens(admin: &signer, to: address, amount: u64) acquires VaultTokenCapabilities {
        let admin_addr = signer::address_of(admin);

        assert!(admin_addr == @vulnerabilities, E_NOT_ADMIN);

        let caps = borrow_global<VaultTokenCapabilities>(admin_addr);
        let minted_coins = coin::mint(amount, &caps.mint_cap);

        // Potential logic for distributing minted tokens
    }

    // Bonus: Privileged emergency withdrawal function
    public entry fun emergency_withdrawal(user: &signer, amount: u64) acquires Vault {
        let user_addr = signer::address_of(user);
        let vault = borrow_global_mut<Vault>(@vulnerabilities);

        if (table::contains(&vault.balances, user_addr)) {
            let balance = table::borrow_mut(&mut vault.balances, user_addr);

            if (*balance >= amount) {
                *balance = *balance - amount;
                vault.total_deposits = vault.total_deposits - amount;
            }
        }
    }

}