package;

import m.cover.coverage.MCoverage;
import m.cover.coverage.CoverageLogger;
import m.cover.coverage.client.PrintClient;
import example.Example;

/**
Main class as @IgnoreCover meta to ensure it is not included in the coverage
*/
@IgnoreCover
class Main
{
	static var logger:CoverageLogger;
	static var completed:Bool = false;
	
	static public function main()
	{
		//execute appliction code
		var example = new Example();

		var client = new CustomPrintClient();
		client.includeHeader = true;
		client.includeMissingBlocks = false;
		client.includeExecutionFrequency = false;
		client.includeClassBreakdown = true;
		client.includePackageBreakdown = true;
		client.includeOverallPercentage = true;
		client.includeSummary = false;

		logger = MCoverage.getLogger();
		logger.addClient(client);
		logger.completionHandler = completionHandler;
		logger.report();//print report to screen

		#if neko
			while(completed != true)
			{
				neko.Sys.sleep(.1);
			}
		#end
	}

	static function completionHandler(percent:Float)
	{
		completed = true;
		trace("Coverage report complete: " + percent + "%");
	}

}

@IgnoreLogging
class CustomPrintClient extends PrintClient
{
	public function new()
	{
		super();
		
	}

	override function printReport()
	{
		super.printReport();
		output += newline;

		var lines = output.split("\n");


		var s = "\n*************************";
		for(line in lines)
		{
			s += "\n*  " + line;
		}
		s += "\n*************************";

		trace(s);
	}
}