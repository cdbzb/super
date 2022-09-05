+ Deferred {
    *fromCallback { |function|
        var def = Deferred();
        function.value({|res| def.value = res });
        def
    }
}
// usage
