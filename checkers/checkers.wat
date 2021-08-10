(module
    (memory $mem 1)

    (global $WHITE i32 (i32.const 2))
    (global $BLACK i32 (i32.const 1))
    (global $CROWN i32 (i32.const 4))

    (global $currentTurn (mut i32) (i32.const 0))

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

    ;; Determine if a piece has been crowned
    (func $isCrowned (param $piece i32) (result i32)
        (i32.eq
            (i32.and (get_local $piece) (get_global $CROWN))
            (get_global $CROWN)
        )
    )

    ;; Determine if a piece is white 
    (func $isWhite (param $piece i32) (result i32)
        (i32.eq
            (i32.and (get_local $piece) (get_global $WHITE))
            (get_global $WHITE)
        )
    )

    ;; Determine if a piece is black 
    (func $isBlack (param $piece i32) (result i32)
        (i32.eq
            (i32.and (get_local $piece) (get_global $BLACK))
            (get_global $BLACK)
        )
    )

    ;; Adds a crown to a piece with no mutation
    (func $withCrown (param $piece i32) (result i32)
        (i32.or (get_local $piece) (get_global $CROWN)) 
    )

    ;; Removes a crown from a piece with no mutation
    (func $withoutCrown (param $piece i32) (result i32)
        (i32.and (get_local $piece) (i32.const 3)) 
    )

    ;; Sets a piece on the board.
    (func $setPiece (param $x i32) (param $y i32) (param $piece i32)
        (i32.store
            (call $offsetForPosition
                (get_local $x) 
                (get_local $y) 
            )
            (get_local $piece)
        ) 
    )

    ;; Detect if values are within range (inclusive high and low)
    (func $inRange (param $low i32) (param $high i32)
                   (param $value i32) (result i32)
        (i32.and
            (i32.ge_s (get_local $value) (get_local $low))
            (i32.le_s (get_local $value) (get_local $high))
        ) 
    )

    ;; Gets a piece from the board. Out of range causes a trap
    (func $getPiece (param $x i32) (param $y i32) (result i32)
        (if (result i32)
            (block (result i32)
                (i32.and
                    (call $inRange
                        (i32.const 0) 
                        (i32.const 7) 
                        (get_local $x) 
                    ) 
                    (call $inRange
                        (i32.const 0) 
                        (i32.const 7) 
                        (get_local $y) 
                    ) 
                )
            )
        )
        (then
            (i32.load
                (call $offsetForPosition
                    (get_local $x)
                    (get_local $y)
                )
            )
        )
        (else
            (unreachable)
        )
    )

)