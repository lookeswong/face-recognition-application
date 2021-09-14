This is a face recognition attendance system project, this repository represents the final year project Software Development Project.

It has 2 directory:
1. face_recog_model :- folder for machine learning model\
2. FaceRecogAttendance :- folder for client application code\

****face_recog_model*****
1. Demo2 :- the machine learning model code\
2. Face_extraction :- the script to extract faces from images\
3. convert_to_coreml :- a script to convert the tensorflow model to cormel format\

*****FaceRecogAttendance*****
1. To test the application, simply run FaceRecogAttendance.xcworkspace in Xcode. You might need to change the bundle identifier and signing capabilities in Xcode.

2. The directory have 3 main folders:
	1. Model - the data model in the application is all stored here
	2. View - the user interfaces of the application - the storyboard 
	3. Controllers - all the controllers in the application are stored here

	4. Some important file:
	GoogleService-info.plist :- a configuration file to access Firebase Storage
	Info.plist :- the client application configuration file
	FaceClassifierV3.mlmodel :- the coreml machine model converted from the tensorflow model.
	Pods :- cocoa pods file that is used in this application
