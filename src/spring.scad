/* [Preview] */
// Preview in lower resolution (always renders in high resolution)
Preview_resolution = 16; // [8, 16, 32, 64, 128]

/* [Spring] */
// Layer height / Z-axis (millimeters)
Spring_height = 2; // [1:0.1:20]
// Spring line thickness (millimeters)
Spring_thickness = 1.75; // [0.5:0.25:20]
// Spring width (millimeters)
Spring_width = 16; // [4:1:60]

/* [Steps] */
// Number of ladder steps / horizontal lines
Steps_count = 15; // [2:1:100]
// Gap size between steps (millimeters)
Steps_gap = 3.75; // [1:0.25:20]

/* [Ends] */
// Set the width of the start and end of the spring
Ends_width = 0; // [0:Default, 2:Half, 1:Full];
// Make the start and end tips of the spring rounded
Ends_rounded = true;

/* [Hidden] */
$fn = $preview ? Preview_resolution : 128;

springHeight = Spring_height;
springThickness = Spring_thickness;
springWidth = Spring_width;
stepsCount = Steps_count;
stepsGap = Steps_gap;
endsWidth = Ends_width;
endsRounded = Ends_rounded;

springWidthMin = stepsGap * 1.5 + springThickness * 2;
partPosition = stepsGap + springThickness;
archDiameter = stepsGap + springThickness * 2;
archPositionX = (springWidth - archDiameter) / 2;
archPositionY = archDiameter / 2;
lineWidth = springWidth - archDiameter;
springDepth = partPosition * (stepsCount - 1) + springThickness;

assert(
	springWidth >= springWidthMin,
	str("Width \"", springWidth, "\" is too small for the current Gap and Thickness settings. Width must be at least: \"", springWidthMin, "\" (Gap x 1.5 + Thickness x 2)")
);

echo(str("Spring depth: ", springDepth, "mm"));

spring();

module spring()
{
	springPositionY = springDepth / -2;
	translate([0, springPositionY])
		union()
		{
			// Spring
			stepsCountMax = stepsCount / 2 - 1;

			for (step = [0 : stepsCountMax])
			{
				translate([0, step * 2 * partPosition])
					part(step == 0);

				if (step < stepsCountMax)
				{
					translate([0, (step + 0.5) * 2 * partPosition])
						mirror([1, 0, 0])
							part();
				}
			}

			// Ends lines
			endsLineWidth = endsWidth == 0
				? lineWidth - (endsRounded ? springThickness / 2 : 0)
				: springWidth / endsWidth - archDiameter / 2 - (endsRounded ? springThickness / 2 : 0);
			linePositionX = endsWidth == 0
				? endsLineWidth / -2 - (endsRounded ? springThickness / 4 : 0)
				: lineWidth / -2;
			linePositionY = (stepsCount - 1) * partPosition;

			mirror([stepsCount % 2 ? 0 : 1, 0, 0])
				line(endsLineWidth, springThickness, springHeight, linePositionX, linePositionY);
			mirror([1, 0, 0])
				line(endsLineWidth, springThickness, springHeight, linePositionX, 0);

			// Ends tips
			if (endsRounded)
			{
				tipPositionX = springWidth / -2 + archDiameter / 2 + endsLineWidth;
				tipPositionY1 = springThickness / 2;
				tipPositionY2 = partPosition * (stepsCount - 1) + springThickness / 2;

				mirror([1, 0, 0])
					tip(springHeight, springThickness, tipPositionX, tipPositionY1);
				mirror([stepsCount % 2 ? 0 : 1, 0, 0])
					tip(springHeight, springThickness, tipPositionX, tipPositionY2);
			}
		}
}

module part(first=false)
{
	if (!first)
	{
		line(lineWidth, springThickness, springHeight, positionY=0);
	}

	arch(springHeight, archDiameter, springThickness, archPositionX, archPositionY);
}

module arch(height, diameter, thickness, positionX="center", positionY="center")
{
	positionX = positionX == "center"
		? diameter / -2
		: positionX;
	positionY = positionY == "center"
		? diameter / -2
		: positionY;
	holeDiameter = diameter - thickness * 2;
	holePositionX = diameter * -1;
	holePositionY = stepsGap / -2;
	cubePositionX = diameter * -1;
	cubePositionY = diameter / -2;

	translate([positionX, positionY])
		difference()
		{
			cylinder(height, d=diameter);
			cylinder(height, d=holeDiameter);
			translate([cubePositionX, cubePositionY])
				cube([diameter, diameter, 3]);
		}
}

module line(sizeX=100, sizeY=100, sizeZ=100, positionX="center", positionY="center")
{
	positionX = positionX == "center"
		? sizeX / -2
		: positionX;
	positionY = positionY == "center"
		? sizeY / -2
		: positionY;

	translate([positionX, positionY])
		cube([sizeX, sizeY, sizeZ]);
}

module tip(height, diameter, positionX="center", positionY="center")
{
	positionX = positionX == "center"
		? diameter / -2
		: positionX;
	positionY = positionY == "center"
		? diameter / -2
		: positionY;

	translate([positionX, positionY])
		cylinder(height, d=diameter);
}
