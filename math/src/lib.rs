#[allow(warnings)]
mod bindings;

use crate::bindings::exports::docs::math::basic::Guest;

struct Component;

impl Guest for Component {
    fn add(lhs: i64, rhs: i64) -> i64 {
        lhs + rhs
    }

    fn sub(lhs: i64, rhs: i64) -> i64 {
        lhs - rhs
    }

    fn mul(lhs: i64, rhs: i64) -> i64 {
        lhs * rhs
    }

    fn div(lhs: i64, rhs: i64) -> i64 {
        lhs / rhs
    }
}

bindings::export!(Component with_types_in bindings);
