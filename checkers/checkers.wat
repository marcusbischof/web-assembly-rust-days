(module
    (memory $mem 1)

    ;; Get the index for x and y, given that we have to access values at (x,y)
    ;; in a contiguous block of memory as opposed to the usual (matrix-esque).
    (func $indexForPosition (param $x i32) (param $y i32) (result i32)
        (i32.add
            (i32.mul
                (i32.const 8) 
                (get_local $y) 
            ) 
            (get_local $x) 
        )
    )

    ;; Use $indexForPosition, combined with the fact that memory isn't index by
    ;; array, but by byte, so we offset by 4 in order to be able to store 32 bit
    ;; ints at each (x,y).
    ;;
    ;; Example math being performed here:
    ;; offsetForPosition(1,2)
    ;; = (x=1 + y=2 * board_size=8) * byte_offset=4
    ;; = 68
    (func $offsetForPosition (param $x i32) (param $y i32) (result i32)
        (i32.mul
            (call $indexForPosition (get_local $x) (get_local $y)) 
            (i32.const 4) 
        )
    )
)