
# ARKit Demo

###  Bottle detection (works with multiple bottles in some cases)

	- The 3d scan of the bottle matters, if it is a good scan it will recognize the bottle better
	- It can distinguish between similar bottles fairly well

###  UI Elements

	- We can anchor any UI elements on an object or image, or even plane
	-  In this case, we have a label of the bottle name above the actual object

### Label detection - image detection

	- If you point the app at a Zackariah Harris bottle a video will start playing
	- The videos need to be the same aspect ratio of the label otherwise it will be cropped weird (this can be customized though)
	- If the bottle is rounded, the video itself needs to be rounded. This is easier to do in an outside program (maybe Unity?) and then imported rather that the phone doing a 2D—> 3D conversion (which should be possible to do though)
	- You can detect many different labels, some online have said that you can get to the hundreds of simultaneous images without any performance issues

### Business Card Detection

	- Very similar to the label detection algorithm
	- This just illustrates that it is possible to track any image or object and do custom actions for that
	- The app will follow the image or object as it moves and then move the accompanying nodes with it (this was new for ARKit 1.5)

  

# Miscellaneous

1.  I have been toying with various other factors to improve experience

	- It will only add one “plane” / “node” per recognized object. This will prevent multiple elements from stacking on top of each other
	- Once you look away from a recognized object, the app will hide the accompanying nodes (improving performance depending on the object’s function)

3.  Plane “Filtering”

	- I originally was toying with the idea of selectively adding planes to track based on distance or size

		- However, this effort proved to be fruitless as the phone is constantly updating planes and it didn’t improve the accuracy at all.

5.  Accuracy

	- Tracking planes is decent, but far from perfect. The app will keep an array of “Plane” objects and will automatically update them as you “scan” more of the scene. This is the role of the `Plane.swift` class.
	- When you wave your hand in front of the camera OR you have a finger on the edge of a plane (i.e: edge of a business card), the app will easily lose track of the plane and the resulting node will start to jitter.

		- This can in theory be smoothed with an advanced algorithm to detect sudden changes. (A low-pass filter could help in this case - however not implemented in this demo)

	- When adding objects or image recognition objects to the project, it will ask you for a physical size. Make sure this is AS ACCURATE AS POSSIBLE. Doing so will result in better results.

