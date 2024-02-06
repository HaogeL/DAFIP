classdef gardner < handle
    %GARDNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gted_pre_valid_sample = 0;
        err_real = 0;
        err_imag = 0;
        count = 1;
        L = 2;
        samples_in_smybol
        param1 = [-1/6;0.5;-0.5;1/6];
        param2 = [0.5;-1;0.5;0];
        param3 = [-1/3;-1/2;1;-1/6];
        param4 = [0;1;0;0];
        underflow = 0;
        uk = 0;
        loopFilter;
    end
    
    methods
        function obj = gardner(damping, BnOverTsymb, L, Kp, K0)
            obj.L = L;
            obj.samples_in_smybol = zeros(1, obj.L);
            obj.loopFilter = PI_loopFilter(damping, BnOverTsymb, L, Kp, K0);
        end
        function err = Gted(obj, newSample)
            gted_mid_sample = cubicLagrangeInterpolation(obj, obj.samples_in_smybol(end-3-obj.L/2), obj.samples_in_smybol(end-2-obj.L/2), obj.samples_in_smybol(end-1-obj.L/2), obj.samples_in_smybol(end-obj.L/2), obj.uk);
            err = real(gted_mid_sample) * (real(obj.gted_pre_valid_sample) - real(newSample)) + imag(gted_mid_sample) * (imag(obj.gted_pre_valid_sample) - imag(newSample));
            obj.gted_pre_valid_sample = newSample;
        end
        
        function inter_value = cubicLagrangeInterpolation(obj, sample0, sample1, sample2, sample3, percentage)
            %samples(1): oldest sample
            %samples(4): latest sample
            %nNextSamples: percentage of sample period

            % For example, cubicLagrangeInterpolation([A0, A1, A2, A3], 0.1) returns
            % interpolant at time of A1 + 0.1(A2-A1)
            % cubicLagrangeInterpolation([A0, A1, A2, A3], 1) returns interpolant at
            % time of A2, which has the same value as A2
            % cubicLagrangeInterpolation([A0, A1, A2, A3], 1.5) returns interpolant at
            % time of A2 + 0.5(A3-A2)
            % cubicLagrangeInterpolation([A0, A1, A2, A3], 2) returns interpolant at
            % time of A3, which has the same value as A3
            samples = [sample0, sample1, sample2, sample3];
            inter_value = samples*obj.param1*(percentage.^3) + samples*obj.param2*(percentage.^2) + samples*obj.param3*percentage + samples*obj.param4;
        end
        
        function [valid_sample, percentage] = check_valid_gted_sample(obj, vn)
            wn = 1/obj.L + vn;
            valid_sample = obj.count < wn;
            if valid_sample
                percentage = obj.count / wn;
            else
                percentage = 0;
            end
            obj.count = mod(obj.count - wn, 1);
        end
       
        
        
        function [synced_sample_valid, uk, base_sample, synced_sample, loopFilterOutput] = run(obj, newSample)
            obj.samples_in_smybol(1:end-1) = obj.samples_in_smybol(2:end);
            obj.samples_in_smybol(end) = newSample;
            
            if(obj.underflow)
                sample_to_gted = cubicLagrangeInterpolation(obj, obj.samples_in_smybol(end-3), obj.samples_in_smybol(end-2), obj.samples_in_smybol(end-1), obj.samples_in_smybol(end), obj.uk);
                err = Gted(obj, sample_to_gted);
                loopFilterOutput = obj.loopFilter.run(err);
                synced_sample_valid = 1;
                synced_sample = sample_to_gted;
                base_sample = obj.samples_in_smybol(end-2);
                uk = obj.uk;
            else
                loopFilterOutput = obj.loopFilter.run(0);
                synced_sample_valid = 0;
                uk = 0;
                synced_sample = 0;
                base_sample = 0;
            end
            
            [obj.underflow, obj.uk] = check_valid_gted_sample(obj, loopFilterOutput);            
        end
        
    end
end

