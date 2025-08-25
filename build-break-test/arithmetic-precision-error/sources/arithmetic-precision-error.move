module address::arithmetic_precision_error{

    use std::signer;
    use std::debug;

    struct Math has key{
        first: u64,
        second: u64,
        third: u64,
        dtm_result: u64,
        mtd_result: u64
    }

    public entry fun initialize(account: &signer){
        let owner = signer::address_of(account);
        let calculation = Math {first: 0,
            second: 0,
            third: 0,
            dtm_result: 0,
            mtd_result: 0};
        move_to(account, calculation);
    }

    public entry fun divide_then_multiply(account: &signer,first: u64, second: u64, third: u64) acquires Math {

        let owner = signer::address_of(account);
        // Calculate: (first / third) * second
        let divide = first / third;
        let multiply = divide* second;

        // Update the stored values
        let math_resource = borrow_global_mut<Math>(owner);
        math_resource.dtm_result = multiply;

    }

    public entry fun multiply_then_divide(account: &signer,first: u64, second: u64, third: u64) acquires Math {

        let owner = signer::address_of(account);
        // Calculate: (first * second) / third
        let multiply = first * second;
        let divide = multiply / third;

        // Update the stored values
        let math_resource = borrow_global_mut<Math>(owner);
        math_resource.mtd_result = divide;

    }

    // Get current values
    #[view]
    public fun get_all_values(account: address): (u64, u64, u64, u64, u64) acquires Math {
        let math_resource = borrow_global<Math>(account);
        (math_resource.first, math_resource.second, math_resource.third, math_resource.dtm_result, math_resource.mtd_result)
    }

    #[view]
    public fun get_dtm_result(account: address): (u64) acquires Math {
        let math_resource = borrow_global<Math>(account);
        math_resource.dtm_result
    }

    #[view]
    public fun get_mtd_result(account: address): (u64) acquires Math {
        let math_resource = borrow_global<Math>(account);
        math_resource.mtd_result
    }

    //Testing
    #[test(account = @0x1)]
    fun test_divide_then_multiply(account: &signer) acquires Math{
        //Initialize
        initialize(account);

        //Divide first
        divide_then_multiply(account, 8, 3, 20);

        let divide_result = get_dtm_result(@0x1);
        debug::print(&divide_result);

        //Multiply first
        multiply_then_divide(account, 8, 3, 20);

        let multiply_result = get_mtd_result(@0x1);
        debug::print(&multiply_result);

    }
}