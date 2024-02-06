classdef PI_loopFilter < handle
    %LOOPFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        damping % damping factor
        BnOverTsymb % loop bandwidth (Bn) normalized to the symbol rate (Ts).
        L % number of samples per symbol
        Kp %detector gain
        K1 %Proportional gain
        K2 %Integrator gain
        K0 % Counter (interpolator controller) gain.
        theta
        stored_value = 0
        
    end
    
    methods
        function obj = PI_loopFilter(damping, BnOverTsymb, L, Kp, K0)
            obj.damping = damping;
            obj.BnOverTsymb = BnOverTsymb;
            obj.L = L;
            obj.Kp = Kp;
            obj.K0 = K0;
            obj.theta = BnOverTsymb/L/(damping+1/4/damping);
            tmp = 1+2*damping*obj.theta+obj.theta*obj.theta;
            KpK0K1 = 4*damping*obj.theta / tmp;
            KpK0K2 = 4*obj.theta*obj.theta / tmp;
            obj.K1 = KpK0K1 / K0 / Kp;
            obj.K2 = KpK0K2 / K0 / Kp;
        end
        
        function outputArg = run(obj,inputArg)
            outputArg = inputArg*obj.K1 + inputArg*obj.K2 + obj.stored_value;
            new_value = inputArg*obj.K2 + obj.stored_value;
            if(length(new_value) > 0)
                obj.stored_value = new_value;
            end
        end
    end
end

