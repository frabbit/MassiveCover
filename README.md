**MassiveCover (MCover) is a cross-platform haXe code coverage framework.**

### How does it work?

MCover injects coverage code at compile-time (using macros) to provide runtime tracking of code coverage. 

MCover is designed to integrate with existing unit testing frameworks to provide detailed metrics on test coverage.



Features
---------------------


### Cross Platform

MCover has been designed to work with any HaXe target. Officially we support the following:

*	ActionScript 2
*	ActionScript 3
*	JavaScript
*	Neko

**NOTE:** MCover requires Haxe 2.0.8


### Compiler Macro

MCover uses a simple macro to inject coverage code into your application at compile time

	--macro massive.mcover.MCover.include('package.name', ['src'])


### Statement coverage

MCover tracks all statement code blocks {...} within your code.


	function test(value:Bool)
	{
		// statement block 1
		if(value)
		{
			// statement block 2
		}
		else
		{
			//statement block 3
		}
	}


### Branch coverage

For code branches with multiple scenarios e.g. (a||b), MCover will log branch results for each individual expression , i.e.:

	if(a || b)

	a = true, b = false;
	a = false, b = true;
	a = true, b = true;
	a = false, b = false; 



### Granular Reporting

MCover stores the contextual information around every statement and branch in order to provide detailed reporting and metrics, including:

*	Package, Class and Method level summaries


		COVERAGE BREAKDOWN BY CLASSES:

	              Result        Methods       Statements    Branches      Class         
	              100%          2/2           2/2           0/0           example.foo.Foo
	              90.48%        11/12         24/26         1/2           Main   
	                  

*	Detailed information on missing statements and branches


		NON-EXECUTED BRANCHES:

		              Main#branch | src/Main.hx:77: characters 10-11 | t

		NON-EXECUTED STATEMENTS:

		              Main#otherTypes | src/Main.hx:107: characters 3-9
		              Main#completionHandler | src/Main.hx:30: characters 2-18


*	Information on statement and branch execution frequency



Getting Started
---------------------

### Step 1.

Install mcover:

	haxelib install mcover

### Step 2.

Add the mcover macro to your build.hxml file:

	-lib mcover
	--macro massive.mcover.MCover.include('', ['src'])

### Step 3.

Print a report at runtime (once your tests/code have finished executing):

	var reporter = MCover.getLogger().createReporter();
	reporter.report();

### Step 4.

View results!
	
	----------------------------------------------------------------
	MCover v1.0 Coverage Report, generated 2011-10-10 11:44:16
	----------------------------------------------------------------

	NON-EXECUTED BRANCHES:

	              Main#branch | src/Main.hx:77: characters 10-11 | t

	NON-EXECUTED STATEMENTS:

	              Main#otherTypes | src/Main.hx:107: characters 3-9
	              Main#completionHandler | src/Main.hx:30: characters 2-18

	COVERAGE BREAKDOWN BY CLASSES:

	              Result        Methods       Statements    Branches      Class         
	              100%          2/2           2/2           0/0           example.foo.Foo
	              100%          3/3           3/3           0/0           example.Example
	              90.48%        11/12         24/26         1/2           Main          
	              100%          1/1           1/1           0/0           InternalClass 

	COVERAGE BREAKDOWN BY PACKAGE:

	              Result        Files         Classes       Package       
	              90.91%        1/1           2/2           [Default]     
	              100%          1/1           1/1           example       
	              100%          1/1           1/1           example.foo   

	----------------------------------------------------------------

	OVERALL STATS SUMMARY:

	total packages      3 / 3               
	total files         3 / 3               
	total classes       4 / 4               
	total methods       17 / 18             
	total statements    30 / 32             
	total branches      1 / 2               

	----------------------------------------------------------------
	RESULT              92.59%              
	----------------------------------------------------------------



## Integrating with MUnit

MCover includes a custom munit print client that automatically prints out coverage results on completion of unit tests. It's pretty basic for now, but does the job!


### Step 1. Add MCover macro to build

Include mcover macro in test.hxml file (see above)

### Step 2. Update TestMain.hx

Replace the default munit PrintClient with massive.mcover.munit.client.PrintClient in TestMain





Usage
---------------------

### Compiler macro

MCover includes a macro for specifying which classes to cover in your application:

	--macro massive.mcover.MCover.include('{package}', {classPaths}, {ignoredClasses})

Where:

*	**package** is the package to filter on (e.g. 'com.example'). Use an empty string to include all packages ('')

*	**classPaths** is an array of classpaths to include in coverage (e.g. ['src']). Default is null (only checks local path (''))

*	**ignoredClasses** is an array of specific classes to ignore (e,g, ['com.example.IgnoredClass']). Default is null


Example:

	--macro massive.mcover.MCover.include('com.example', ['src'], null)

Note: Only use single quotation marks (' ') to avoid compiler issues on windows platforms



### Runtime reporting

#### Step 1. 
At runtime, MCover cam automatically log code execution blocks.

To capture coverage initialize a coverage reporter (CoverageReporter):

	var reporter = MCover.getLogger().createReporter();

#### Step 2. 
To generate the results call MCoverRunner.report() once your unit tests (or other code) have completed:

	reporter.report();

By default these are sent to a generic TraceClient that outputs to the screen.

You can set multiple custom clients (CoverageReportClient) if required:

	reporter.addClient(new massive.mcover.client.PrintClient());



### Coverage Reports

The current output (see example above) provides a basic percentage breakdown of code blocks that have been executed. It also provides summaries for individual classes and packages within the class path:



Code Coverage
---------------------

### Overview

MCover reports coverage on code statements and branches

*	**Statement** coverage measures whether a block of code as been executed


		function foo()
		{
			//one or more lines of code in a statement block

		}


*	**Branch** coverage measures possible code branches where multiple scenarios are possible by recording the boolean result of each operator. In the example if(a||b), branch coverage will determine if 'a' and 'b' have been evaluated to both 'true' and 'false' during execution.


		e.g.
		function foo(a:Bool, b:Bool)
		{
			if(a||b)
			{
				//do someting
			}
		}

		foo(true, false);
		for(false, true);


*	**Method** coverage measures if one or more statements within a method was entered during execution.

*	**Class** coverage measures if one or more methods within a class (static or instance) was entered during execution.

*	**File** coverage measures if one or more classes within a file was entered during execution.

*	**Package** coverage measures if one or more files within a file was entered during execution.


### Coverage Percentage

MCover uses the same formula as Clover (Java Coverage tool) for calculating a coverage percentage

	TPC = (BT + BF + SC + MC)/(2*B + S + M)
 
where
 
	BT - branches that evaluated to "true" at least once
	BF - branches that evaluated to "false" at least once
	SC - statements covered
	MC - methods entered
	 

	B - total number of branches
	S - total number of statements
	M - total number of methods



### Current Implementation
	

MCover is still in development but it already covers most functional expressions including:

Currently supported statement blocks

*	class methods

*	if/else statements

*	switch case and default statements

*	for loop statements

*	while loop statements

*   try/catch statements

*	inline functions, arrays and objects (e.g. var o = {f:function(){var a = [1,2,3]}})


Currently supported branch scenarios

*	binary operations like a || b, a == b, a != b, a && b

*	comparisons like a == b, a < b, a <= b, a > b, a >= b

*	terniary operations like a = b ? c : d

*	if/else  conditions

*	switch case conditions (and default)

*	while conditions




### Customising PrintClient report output

You can customise the detail of reports generated by the default PrintClient

	var printClient = new PrintClient();
	printClient.includeMissingBlocks = true; //defaults to true;
	printClient.includeBlockExecutionCounts = true;//defaults to false;

*includeBlockExecutionCount* will include a list of all branches and statements sorted by highest to lowest frequency (how often they were executed). Defaults to false

*includeMissingBlocks* includes an list of all statements and branches that have not been executed at all (name, file, position). Defaults to true.


Examples
---------------------

See the included example for a working test case

	/example

You can also run the unit tests (requires munit haxelib) to see coverage of the coverage classes :)


Advanced Usage
---------------------

#### Setting a custom reporter

You can specify a custom reporter by passing through a class that implements CoverageReporter. By default an instance of CoverageReporterImpl is created.

	MCover.getLogger().createReporter(CoverageReporterImpl);

#### Ignoring individual classes or methods

You can flag a class or method to be excluded from coverage using @IgnoreCover metadata
	

	@IgnoreCover class Foo
	{
		public function new()
		{
			
		}
	}


Or

	class Foo
	{
		public function new()
		{
			
		}

		@IgnoreCover 
		function ignore()
		{
			
		}
	}
	


