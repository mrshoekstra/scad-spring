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
// Make the start and end tips of the spring rounded
Ends_rounded = true;

/* [Hidden] */
$fn = $preview ? Preview_resolution : 128;
springHeight = Spring_height;
springThickness = Spring_thickness;
springWidth = Spring_width;
stepsCount = Steps_count;
stepsGap = Steps_gap;
endsRounded = Ends_rounded;

minWidth = stepsGap * 1.5 + springThickness * 2;
partPosition = stepsGap + springThickness;
archOuterDiameter = stepsGap + springThickness * 2;
archPositionX = (springWidth - archOuterDiameter) / 2;
archPositionY = archOuterDiameter / 2;
lineWidth = springWidth - archOuterDiameter;
springDepth = partPosition * (stepsCount - 1) + springThickness;

assert(
	springWidth >= minWidth,
	str("Width \"", springWidth, "\" is too small for the current Gap and Thickness settings. Width must be at least: \"", minWidth, "\" (Gap x 1.5 + Thickness x 2)")
);

echo(str("Spring depth: ", springDepth, "mm"));

spring();

module spring()
{
	springPositionY = springDepth / -2;
	translate([0, springPositionY])
		union()
		{
			if (endsRounded)
			{
				tipPositionX = (springWidth - archOuterDiameter) * -0.5;
				tipPositionY = springThickness / 2;
				tip(springHeight, springThickness, tipPositionX, tipPositionY);

				tipPositionX2 = (springWidth - archOuterDiameter) * (stepsCount % 2 ? 0.5 : -0.5);
				tipPositionY2 = partPosition * (stepsCount - 1) + springThickness / 2;
				tip(springHeight, springThickness, tipPositionX2, tipPositionY2);
			}

			stepsCountMax = stepsCount / 2 - 1;

			for (step = [0 : stepsCountMax])
			{
				translate([0, step * 2 * partPosition])
					part();

				if (step < stepsCountMax)
				{
					translate([0, (step + 0.5) * 2 * partPosition])
						mirror([1, 0, 0])
							part();
				}
			}

			linePositionY = (stepsCount - 1) * partPosition;
			line(lineWidth, springThickness, springHeight, positionY=linePositionY);
		}
}

module part()
{
	line(lineWidth, springThickness, springHeight, positionY=0);
	arch(springHeight, archOuterDiameter, springThickness, archPositionX, archPositionY);
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
