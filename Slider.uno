namespace Native {
    using Uno;
    using Uno.UX;
    using Fuse.Controls;

    public interface ISliderHost
    {
        void OnValueChanged(float newValue);
    }

    public interface ISlider
    {
        float Value { set; }
    }

    public class MySlider: Control, ISliderHost
    {
        float _value;
        [UXOriginSetter("SetValue")]
        public float Value
        {
            get { return _value; }
            set { SetValue(value, this); }
        }

        static readonly Selector _valueName = "Value";
        public void SetValue(float newValue, IPropertyListener origin)
        {
            if (_value != newValue)
            {
                _value = newValue;
                OnPropertyChanged(_valueName, origin);
            }
            if (origin != null)
            {
                var ns = NativeSlider;
                if (ns != null)
                    ns.Value = newValue;
            }
        }

        void ISliderHost.OnValueChanged(float newValue)
        {
            SetValue(newValue, null);
        }

        ISlider NativeSlider
        {
            get { return NativeView as ISlider; }
        }
    }
}

namespace Native.iOS
{
    using Uno;
    using Uno.UX;
    using Uno.Compiler.ExportTargetInterop;
    using Fuse.Controls.Native.iOS;

    [Require("Xcode.Plist.Element", "<key>MGLMapboxAccessToken</key><string>pk.eyJ1IjoicGF2ZWxrb3N0ZW5rbyIsImEiOiJjajVmYWYwMW8xMWc0MzNvZGt1ajZhdHlzIn0.v3z5PDM8pAbRZZnCHWka5Q<string/>")]

    //[Require("Source.Include", "UIKit/UIKit.h")]
    //[Require("Source.Include", "MapKit/MapKit.h")]
    [extern(iOS) Require("Source.Include", "Mapbox/Mapbox.h")]
    [extern(iOS) Require("Xcode.EmbeddedFramework", "@('iOS/frameworks/Mapbox.framework':Path)")]
    extern(iOS) public class MySlider: LeafView, ISlider
    {
        [UXConstructor]
        public MySlider([UXParameter("Host")]ISliderHost host) : base(Create()) { }

        [Foreign(Language.ObjC)]
        static ObjC.Object Create()
        @{
            // Slider OK
            //
            //::UISlider* slider = [[::UISlider alloc] init];
            //[slider setMinimumValue:   0.0f];
            //[slider setMaximumValue: 100.0f];
            // map example
            //UIView *mvc = [[UIView alloc] init];
            //MKMapView* mv = [[MKMapView alloc] init];

            // return
            //return mv;
            
            //
            // MapKit
            //
            /*
            UIView *mvc = [[UIView alloc] init];
            MKMapView* mv = [[MKMapView alloc] init];
            mv.frame = mvc.bounds;
            //mv.frame = self.view.bounds;
            mv.translatesAutoresizingMaskIntoConstraints = YES;
            mv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [mvc addSubview:mv];
            return mvc;
            */
            UIView *mvc = [[UIView alloc] init];
            NSURL *url = [NSURL URLWithString:@"mapbox://styles/mapbox/streets-v10"];
            CGRect rect = CGRectMake(0, 0, 100, 100);
            MGLMapView *mapView = [[MGLMapView alloc] initWithFrame:rect];
            mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [mapView setCenterCoordinate:CLLocationCoordinate2DMake(59.31, 18.06)
                               zoomLevel:9
                                animated:NO];
            [mvc addSubview:mapView];
            return mvc;
        @}

        public float Value
        {
            get { return GetValue(Handle); }
            set { SetValue(Handle, value); }
        }

        [Foreign(Language.ObjC)]
        static float GetValue(ObjC.Object handle)
        @{
            ::UISlider* slider = (::UISlider*)handle;
            return [slider value];
        @}

        [Foreign(Language.ObjC)]
        static void SetValue(ObjC.Object handle, float value)
        @{
            ::UISlider* slider = (::UISlider*)handle;
            [slider setValue:value animated:false];
        @}

        void OnValueChanged()
        {
            // TODO: implement value changed callback
        }
    }

    extern(!iOS) public class MySlider
    {
        [UXConstructor]
        public MySlider([UXParameter("Host")]ISliderHost host) { }
    }
}