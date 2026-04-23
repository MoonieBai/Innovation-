import { useState } from "react";
import { Navigation, MapPin, Compass, Map } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { MapComponent } from "./MapComponent";

interface GPSNavigationProps {
  latitude: number;
  longitude: number;
  altitude: number;
  heading: number;
}

export function GPSNavigation({ latitude, longitude, altitude, heading }: GPSNavigationProps) {
  const [isNavigating, setIsNavigating] = useState(false);

  const formatCoordinate = (coord: number, isLat: boolean) => {
    const direction = isLat ? (coord >= 0 ? "N" : "S") : (coord >= 0 ? "E" : "W");
    return `${Math.abs(coord).toFixed(6)}° ${direction}`;
  };

  return (
    <Card className="bg-gray-800">
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center justify-between text-white">
          <span>GPS Navigation</span>
          <Navigation className={`size-6 ${isNavigating ? 'text-blue-500' : 'text-gray-400'}`} />
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Map Display */}
        <div className="h-64 rounded-lg overflow-hidden border-2 border-gray-700">
          <MapComponent latitude={latitude} longitude={longitude} />
        </div>

        <div className="grid grid-cols-2 gap-3">
          <div className="space-y-1 col-span-2">
            <div className="flex items-center gap-1 text-sm text-white">
              <MapPin className="size-4" />
              <span>Location</span>
            </div>
            <p className="text-lg font-semibold text-white">Birmingham, UK</p>
          </div>
          
          <div className="space-y-1">
            <div className="flex items-center gap-1 text-sm text-white">
              <Compass className="size-4" />
              <span>Heading</span>
            </div>
            <p className="font-mono text-sm text-white">{heading}°</p>
          </div>
          
          <div className="space-y-1">
            <div className="flex items-center gap-1 text-sm text-white">
              <Map className="size-4" />
              <span>Altitude</span>
            </div>
            <p className="font-mono text-sm text-white">{altitude.toFixed(0)}m</p>
          </div>
        </div>

        <div className="pt-2 space-y-2">
          <Button 
            className="w-full" 
            onClick={() => setIsNavigating(!isNavigating)}
            variant={isNavigating ? "destructive" : "default"}
          >
            {isNavigating ? "Stop Navigation" : "Start Navigation"}
          </Button>
          
          {isNavigating && (
            <div className="bg-blue-900/50 border border-blue-500 rounded-md p-2">
              <p className="text-xs text-white">🧭 Navigation active - Follow the directions</p>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}