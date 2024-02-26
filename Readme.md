<html>
<head>
	<title> ETC Test Parser Read me File</title>
</head>
<body>
<h1>ETC Test Parser</h1>
<hr/>

<H2>Features as of V1.0.0</h2>
<ul><strong>Current Features</strong>
<li>Reads all .htm/html files from the "./HTML_Files" directory.</li>
<Li>Parses the students name from the file</li>
<li>Tallies all missed questions, by objectives per Mod</li>
<Li>Outputs two files into the "./Output_Files" directory based on students name; a text file and .csv file</li>
<li>Calculates the students Grades</li>
</ul>
<hr/>

<h2>Usage</h2>
<ol>
<li>Go to "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser"</li>
<Li>Choose which Mod you wish to parse (3 or 9)  (Note:  Currently Programming/Scripting Module objectives are prefixed with '9'.)</li>
<li>Save each test you wish to parse in the "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser\Mod#\HTML_Files" folder</li>
<Li>Right Click on the "testParser_mod#.ps1", and choose "Run with PowerShell" from the menu.</li>
<li>A screen will pop up as the program runs, but will not pause.  This is normal behavior.</li>
<li>Check out the "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser\Mod#\Output_Files" folder for the results.</li>
<Li>Review the text files, and then copy the csv files into the remediation file.</li>
<LI>DONE!</li>
</ol>
<hr/>

<h2>Versions/To DO</h2>
<UL>
  <li><strong>Test paser v0.0.0</strong> - Initial Working Code Block that works on the Unit Test.</li>
</UL>
<ul><strong>To Do for Verison v1.0.0</strong></li>
<strike>
<li>Add documentation to code</li>
<li>General Code clean up/uniformity</li>
<li>Add saved output - report file from last run.</li>
<li>Add support for CSV saves</li>
<li>Add support for multiple html files in the same directory</li>
</strike>
<li><em>Add Auto detecting for the Mod# in the objective</em> --> Push to next version due to need to track # questions on the test and the # of objectives to track.</li>
</ul>
<ul><Strong>To Do for Future Versions</strong>
<li>Add Auto login feature</li>
<Li>Create a single file text file as an output as well.</li>
<li>Add support to download tests from ETC server by group</li>
<li>Add student object???</li>
</ul>
<hr/>
</body>
</html>
