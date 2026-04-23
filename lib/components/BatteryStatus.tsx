import { Battery, BatteryCharging, Sun } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Progress } from "./ui/progress";

interface BatteryStatusProps {
  batteryLevel: number;
  isCharging: boolean;
  solarPower: number;
}

export function BatteryStatus({ batteryLevel, isCharging, solarPower }: BatteryStatusProps) {
  const getBatteryColor = () => {
    if (batteryLevel > 60) return "text-green-500";
    if (batteryLevel > 30) return "text-yellow-500";
    return "text-red-500";
  };

  const getProgressColor = () => {
    if (batteryLevel > 60) return "bg-green-500";
    if (batteryLevel > 30) return "bg-yellow-500";
    return "bg-red-500";
  };

  return (
    <Card className="bg-gray-800">
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center justify-between text-white">
          <span>Solar Battery</span>
          {isCharging ? (
            <BatteryCharging className={`size-6 ${getBatteryColor()}`} />
          ) : (
            <Battery className={`size-6 ${getBatteryColor()}`} />
          )}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div>
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-white">Battery Level</span>
            <span className={`font-semibold ${getBatteryColor()}`}>
              {batteryLevel.toFixed(2)}%
            </span>
          </div>
          <Progress value={batteryLevel} className="h-3" indicatorClassName={getProgressColor()} />
        </div>
        
        <div className="flex items-center justify-between pt-2 border-t border-gray-700">
          <div className="flex items-center gap-2">
            <Sun className="size-5 text-yellow-500" />
            <span className="text-sm text-white">Solar Input</span>
          </div>
          <span className="font-semibold text-white">{solarPower.toFixed(2)}W</span>
        </div>
      </CardContent>
    </Card>
  );
}