package m.cover.coverage.munit.client;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import m.cover.coverage.munit.client.MCoverPrintClient;
import massive.munit.TestResult;
import m.cover.coverage.CoverageReportClientMock;
import massive.munit.ITestResultClient;
import m.cover.coverage.CoverageLoggerMock;
import m.cover.coverage.data.Coverage;
import m.cover.coverage.data.NodeMock;
/**
* Auto generated MassiveUnit Test Class  for m.cover.coverage.munit.client.MCoverPrintClient 
*/
class MCoverPrintClientTest 
{
	var instance:MCoverPrintClient; 
	var munitClient:AdvancedTestResultClientMock;
	var result:TestResult;

	var coverageClient:CoverageReportClientMock;
	var coverageLogger:CoverageLoggerMock;

	var completionCount:Int;

	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
		munitClient = new AdvancedTestResultClientMock();
		
		coverageClient = new CoverageReportClientMock();
		coverageLogger = new CoverageLoggerMock();
		coverageLogger.setCoverage(new Coverage());
		result = new TestResult();	
		
		instance = new MCoverPrintClient(munitClient,coverageClient,coverageLogger);
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	@Test
	public function shouldSetIdInConstructor():Void
	{
		instance = new MCoverPrintClient(munitClient,coverageClient,coverageLogger);
		Assert.areEqual(MCoverPrintClient.DEFAULT_ID, instance.id);
	}

	@Test
	public function shouldUseCustomClient():Void
	{
		result.passed = true;
		instance.addPass(result);
		Assert.areEqual(1, munitClient.passCount);
	}

	@Test
	public function shouldCallClientAddPass()
	{
		result.passed = true;
		instance.addPass(result);
		Assert.areEqual(1, munitClient.passCount);
	}

	@Test
	public function shouldCallClientAddFail()
	{
		result.passed = false;
		instance.addFail(result);
		Assert.areEqual(1, munitClient.failCount);
	}

	@Test
	public function shouldCallClientAddError()
	{
		result.passed = false;
		result.error = "error";
		instance.addError(result);
		Assert.areEqual(1, munitClient.errorCount);
	}

	@Test
	public function shouldCallClientAddIgnore()
	{
		result.ignore = true;
		instance.addIgnore(result);
		Assert.areEqual(1, munitClient.ignoreCount);
	}

	@Test
	public function shouldUpdateCurrentTestIfTestClassChanges()
	{
		instance.setCurrentTestClass("a");
		Assert.areEqual("a", munitClient.currentTestClass);
		Assert.areEqual(1, munitClient.testClasses.length);

		instance.setCurrentTestClass("a");
		Assert.areEqual("a", munitClient.currentTestClass);
		Assert.areEqual(1, munitClient.testClasses.length);

		instance.setCurrentTestClass("b");
		Assert.areEqual("b", munitClient.currentTestClass);
		Assert.areEqual(2, munitClient.testClasses.length);
	}


	@Test
	public function shouldUpdateLoggerCurrentTestIfTestChanges()
	{
		var logger = coverageLogger;
		logger.currentTest = null;

		instance.setCurrentTestClass("aTest");
		Assert.areEqual(logger.currentTest,"a");

		instance.setCurrentTestClass("a");
		Assert.areEqual(logger.currentTest,null);

		instance.setCurrentTestClass("aTest");
		Assert.areEqual(logger.currentTest,"a");

		instance.setCurrentTestClass("bTest");
		Assert.areEqual(logger.currentTest,"b");
	}

	@Test
	public function shouldCreateCoverageForCurrentTestClass()
	{
		var coverage = coverageLogger.coverage;
		var branch = NodeMock.createBranch();
		var statement = NodeMock.createStatement();

		coverage.addBranch(branch);
		coverage.addStatement(statement);
		instance.setCurrentTestClass("package.classTest");
		
		branch.trueCount = 1;
		branch.falseCount = 0;
		statement.count = 0;
		instance.setCurrentTestClass("item2Test");
		
		var coverageResult = munitClient.testCoverage;

		Assert.isNotNull(coverageResult);
		Assert.areEqual("package.class", coverageResult.className);
		Assert.areEqual(25, coverageResult.percent);
		Assert.areEqual(2, coverageResult.blocks.length);
	}

	@Test
	public function shouldCallClientReportFinalStatistics()
	{
		instance.reportFinalStatistics(3,1,1,1,1,0);
		Assert.areEqual(3, munitClient.finalTestCount);
	}

	
	@Test
	public function shouldCallCompletionHandler()
	{
		completionCount = 0;
		instance.completionHandler = completionHandler;
		instance.reportFinalStatistics(3,1,1,1,1,0);

		Assert.areEqual(1, completionCount);
	}


	//////
	function completionHandler(client:ITestResultClient)
	{
		 completionCount ++;
	}

	function populateCoverage()
	{
		var coverage = coverageLogger.coverage;

		var item1 = cast(coverage.getItemByName("item1", NodeMock), NodeMock);
		var item2 = cast(coverage.getItemByName("item2", NodeMock), NodeMock);
		var item3 = cast(coverage.getItemByName("item3", NodeMock), NodeMock);
	}

}