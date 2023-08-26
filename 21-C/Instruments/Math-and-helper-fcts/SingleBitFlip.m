 function [new_state] = SingleBitFlip(current_state, channel_to_flip)
            
            new_state = bitxor(current_state,bitshift(1,channel_to_flip-1));
            
        end