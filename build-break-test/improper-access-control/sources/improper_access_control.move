module improper_access_control::insecure_transaction {
    use std::signer;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;

    //Errors
    const INSUFFICIENT_BALANCE: u64 = 1;
    const NOT_AUTHORIZED: u64 = 2;

    //Resource creation - keeping original structure
    struct ATM has key {
        value: u64,
    }

    //Initialize the resource
    public fun initialize(account: &signer) {
        let address = signer::address_of(account);
        if (!exists<ATM>(address)) {
            move_to(account, ATM { value: 0 });
        }
    }

    // Deposit tokens to ATM
    public entry fun deposit_to_atm(account: &signer, amount: u64) acquires ATM {
        let account_addr = signer::address_of(account);

        // Ensure account has sufficient balance
        assert!(coin::balance<AptosCoin>(account_addr) >= amount, INSUFFICIENT_BALANCE);

        // Get ATM resource
        let atm = borrow_global_mut<ATM>(account_addr);

        // Update ATM balance
        atm.value = atm.value + amount;
    }

    //Send to another address
    public entry fun send_tokens(from: &signer, to_address: address, amount: u64) acquires ATM {
        let sender = signer::address_of(from);
        assert!(coin::balance<AptosCoin>(sender) >= amount, INSUFFICIENT_BALANCE);

        // Get ATM and update balance
        let atm = borrow_global_mut<ATM>(sender);
        assert!(atm.value >= amount, INSUFFICIENT_BALANCE);
        atm.value = atm.value - amount;

        // Transfer tokens
        coin::transfer<AptosCoin>(from, to_address, amount);
    }

    //Withdraw token from account
    public entry fun withdraw_tokens(account: &signer, amount: u64) acquires ATM {
        let account_addr = signer::address_of(account);
        // Ensure account has sufficient balance
        assert!(coin::balance<AptosCoin>(account_addr) >= amount, INSUFFICIENT_BALANCE);

        // Get ATM and update balance
        let atm = borrow_global_mut<ATM>(account_addr);
        assert!(atm.value >= amount, INSUFFICIENT_BALANCE);
        atm.value = atm.value - amount;

        // Withdraw tokens (transfer to sender)
        coin::transfer<AptosCoin>(account, account_addr, amount);
    }

    // Get ATM balance
    public fun get_atm_value(addr: address): u64 acquires ATM {
        let atm = borrow_global<ATM>(addr);
        atm.value
    }

    /// Get account balance
    public fun get_balance(addr: address): u64 {
        coin::balance<AptosCoin>(addr)
    }
}