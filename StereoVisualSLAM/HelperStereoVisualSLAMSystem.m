%% Hrishikesh Naramparambath
% 21BRS1142

classdef HelperStereoVisualSLAMSystem < matlab.System
    properties(Nontunable)
        FocalLength    = [1109 1109]
        PrincipalPoint = [640 360]
        ImageSize      = [720 1280]
        Baseline       = 0.5
    end

    properties(Access = private)
        VslamObj
    end

    methods
        function obj = HelperStereoVisualSLAMSystem(varargin)
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access = protected)
        function setupImpl(obj)
            intrinsics = cameraIntrinsics(obj.FocalLength, obj.PrincipalPoint, obj.ImageSize);
           
            obj.VslamObj = stereovslam(intrinsics,obj.Baseline,DisparityRange=[0,32],...
                LoopClosureThreshold=150,MaxNumPoints=800,SkipMaxFrames=10,TrackFeatureRange=[30,120]);
        end

        function isTrackingLost = stepImpl(obj, ILeft, IRight)
            addFrame(obj.VslamObj,ILeft, IRight);
            if hasNewKeyFrame(obj.VslamObj)
                plot(obj.VslamObj);
            end
            isTrackingLost=~checkStatus(obj.VslamObj);
        end

        function resetImpl(obj)

        end

        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);
        end

        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end
       
        function ds = getDiscreteStateImpl(obj)
            ds = struct([]);
        end

        function flag = isInputSizeMutableImpl(obj,index)
            flag = false;
        end

        function [out1] = getOutputSizeImpl(obj)
            out1= [1 1];
        end

        function [out1] = getOutputDataTypeImpl(obj)
            out1 = "boolean";
        end

        function [out1] = isOutputComplexImpl(obj)
            out1 = false;
        end

        function [out1] = isOutputFixedSizeImpl(obj)
            out1 = true;
        end

        function icon = getIconImpl(obj)
            icon = ["Helper","Stereo Visual", "SLAM System"];
        end

        function [name1,name2] = getInputNamesImpl(obj)
            name1 = 'ILeft';
            name2 = 'IRight';
        end

        function [name1] = getOutputNamesImpl(obj)
            name1 = 'Tracking Lost';
        end
    end

    methods(Static, Access = protected)
        function header = getHeaderImpl
            header = matlab.system.display.Header(mfilename("class"));
        end

        function group = getPropertyGroupsImpl
            group = matlab.system.display.Section(mfilename("class"));
        end

        function flag = showSimulateUsingImpl
            flag = false;
        end
    end
end
