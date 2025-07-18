module improper_access_control::insecure_transaction {

    use std:: signer;
    use std::debug;

    /// Error codes
    const ERROR_NOT_OWNER: u64 = 1;
    const ERROR_INSUFFICIENT_BALANCE: u64 = 2;
    const ERROR_VAULT_DOESNT_EXIST: u64 = 3;
    const ERROR_IN_BALANCE: u64 = 4;

    //Create a vault
    struct Vault has key {
        owner: address,
        vault_Coin: u64,
    }

    // Initialize the vault
    public entry fun initialize_vault(account: &signer) {
        let owner = signer::address_of(account);
        let vault = Vault { owner, vault_Coin: 0 };
        move_to(account, vault);
    }

    // Deposit coins
    public entry fun deposit(account: &signer, amount: u64) acquires Vault {
        let owner = signer::address_of(account);

        //Check if vault exists
        assert!(exists<Vault>(owner), ERROR_VAULT_DOESNT_EXIST);

        let vault = borrow_global_mut<Vault>(owner);

        // Verify ownership
        assert!(vault.owner == owner, ERROR_NOT_OWNER);

        vault.vault_Coin += amount;
    }

    // Transfer coins
    public entry fun transfer(account: &signer, from:address, to: address, amount: u64) acquires Vault {
        //assert vaults are present
        assert!(exists<Vault>(from), ERROR_VAULT_DOESNT_EXIST);
        assert!(exists<Vault>(to), ERROR_VAULT_DOESNT_EXIST);

        let sender_vault = borrow_global_mut<Vault>(from);
        // Verify ownership of sender
        //assert!(sender_vault.owner == address_of(account), ERROR_NOT_OWNER);
        assert!(signer::address_of(account) == from, ERROR_NOT_OWNER);

        // Check balance
        assert!(sender_vault.vault_Coin >= amount, ERROR_INSUFFICIENT_BALANCE);

        //Deduct from sender vault
        sender_vault.vault_Coin -= amount;

        //Add to sender vault
        let to_vault = borrow_global_mut<Vault>(to);
        to_vault.vault_Coin += amount;
    }

    // Withdraw coins
    public entry fun withdraw(account: &signer, amount: u64) acquires Vault {
        let owner = signer::address_of(account);
        //Check if vault exists
        assert!(exists<Vault>(owner), ERROR_VAULT_DOESNT_EXIST);

        let vault = borrow_global_mut<Vault>(owner);

        // Verify ownership
        assert!(vault.owner == owner, ERROR_NOT_OWNER);

        //Check sufficient balance
        assert!(vault.vault_Coin >= amount, ERROR_INSUFFICIENT_BALANCE);

        vault.vault_Coin -= amount;
    }

    /// Get the current balance of the vault
    public fun get_balance(owner: address): u64 acquires Vault {
        // assert!(exists<Vault>(owner), ERROR_VAULT_DOESNT_EXIST);
        let vault = borrow_global<Vault>(owner);
        vault.vault_Coin
    }

    //Testing
    #[test(account = @0x1, recepient = @0x1234)]
    fun test_vault_operations(account: signer, recepient: &signer) acquires Vault {
        // Initialize vaults
        initialize_vault(&account);
        initialize_vault(recepient);

        // Test deposit
        deposit(&account, 100);
        assert!(get_balance(signer::address_of(&account)) == 100, 0);

        // Test withdraw
        withdraw(&account, 30);
        assert!(get_balance(signer::address_of(&account)) == 70, 1);

        // Test Transfer
        transfer(&account, signer::address_of(&account),signer::address_of(recepient), 7);
        assert!(get_balance(signer::address_of(recepient)) == 7, 4);

        debug::print(&get_balance(signer::address_of(&account)));
        debug::print(&get_balance(signer::address_of(recepient)));

    }

    #[test(account = @0x2, hacker = @0x333)]
    fun test_access_control(account: &signer, hacker: &signer) acquires Vault {
        initialize_vault(account);
        initialize_vault(hacker);

        //Deposit 150 coins
        deposit(account, 150);

        //Check balance of hacker
        assert!(get_balance(signer::address_of(hacker)) == 0, 4);

        //transfer using hacker
        transfer(hacker, signer::address_of(account), signer::address_of(hacker),150);
        assert!(get_balance(signer::address_of(hacker)) == 150, 4);

        debug::print(&get_balance(signer::address_of(account)));
        debug::print(&get_balance(signer::address_of(hacker)));

    }
}