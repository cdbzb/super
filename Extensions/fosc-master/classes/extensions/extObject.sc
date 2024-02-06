/* ------------------------------------------------------------------------------------------------------------
• Object
------------------------------------------------------------------------------------------------------------ */
+ Object {
    /* --------------------------------------------------------------------------------------------------------
    • assert
    -------------------------------------------------------------------------------------------------------- */
    assert { |method, argName, val|
        var bool;
        
        bool = try { this.asBoolean } { false };
        if (bool) { ^nil };

        if (method.isNil) {
            ^MethodError(thisMethod, this).throw;
        } {
            //^FoscValueError(method, argName, val).throw;
            ^throw("ERROR: %:%: bad value for '%': %.".format(this, method, argName, val.cs));
        };
    }
}
