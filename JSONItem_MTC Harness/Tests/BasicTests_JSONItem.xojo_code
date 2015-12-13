#tag Class
Protected Class BasicTests_JSONItem
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Sub IllegalStringTest()
		  dim j as JSONItem
		  
		  dim badStrings() as string = Array( Chr( 13 ), Chr( 9 ), Chr( 8 ), Chr( 5 ), Chr( 29 ) )
		  
		  for each s as string in badStrings
		    dim load as string = "[""this" + s + "that""]"
		    #pragma BreakOnExceptions false
		    try
		      j = new JSONItem( load )
		    catch err as JSONException
		      Assert.Fail( EncodeHex( s ).ToText + " should not have failed" )
		      return
		    end try
		    #pragma BreakOnExceptions true
		  next
		  
		  Assert.Pass "All tests passed"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadAdditionalTest()
		  dim j as new JSONItem
		  j.Value( "one" ) = 1.0
		  
		  j.Load( "{""one"" : ""that"", ""two"": ""this""}" )
		  Assert.AreEqual( "that", j.Value( "one" ).StringValue )
		  Assert.AreEqual( "this", j.Value( "two" ).StringValue )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadEncodingTest()
		  #pragma BreakOnExceptions false
		  
		  const kOriginal = "[""abc""]"
		  
		  dim testString as string
		  dim j as JSONItem
		  
		  testString = kOriginal
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.DefineEncoding( nil )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF16BE )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF16LE )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF32BE )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF32LE )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF16BE )
		  testString = testString.DefineEncoding( nil )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF16LE )
		  testString = testString.DefineEncoding( nil )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF32BE )
		  testString = testString.DefineEncoding( nil )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		  testString = kOriginal.ConvertEncoding( Encodings.UTF32LE )
		  testString = testString.DefineEncoding( nil )
		  j = new JSONItem( testString )
		  Assert.AreSame( "abc", j( 0 ).StringValue )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadInterruptionTest()
		  dim j as JSONItem
		  dim load as string = "{""first"" : 1.0, ""second"" : interrupt}"
		  
		  #pragma BreakOnExceptions false
		  
		  try
		    j = new JSONItem( load )
		    Assert.Fail( "Loading through the Constructor should have failed" )
		    return
		  catch err as JSONException
		  end 
		  
		  Assert.IsTrue( j is nil, "An interrupted load in the Constructor should lead to a nil object" )
		  
		  j = new JSONItem
		  try
		    j.Load load
		    Assert.Fail( "Calling Load should have failed" )
		    return
		  catch err as JSONException
		  end
		  
		  Assert.IsTrue( j.Count = 0, "Interrupted load should not have a value" )
		  
		  j = new JSONItem
		  j.Value( "zero" ) = true
		  
		  try
		    j.Load load
		    Assert.Fail( "Loading into an existing Object should have failed" )
		    return
		  catch err as JSONException
		  end
		  
		  Assert.IsTrue( j.Count = 1 and j.Value( "zero" ) = true, "Interrupted load should not have replaced value" )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TextTest()
		  dim j as new JSONItem
		  
		  dim t1 as text = "hi"
		  dim k1 as text = "1"
		  
		  dim t2 as text = "there"
		  dim k2 as text = "2"
		  
		  j.Append t1
		  j.Append t2
		  
		  #pragma BreakOnExceptions false
		  Assert.AreEqual( "[""hi"",""there""]", j.ToString )
		  #pragma BreakOnExceptions default
		  
		  j = new JSONItem
		  j.Value( k1 ) = t1
		  j.Value( k2 ) = t2
		  
		  #pragma BreakOnExceptions false
		  dim asJSONString as string = j.ToString
		  #pragma BreakOnExceptions default
		  
		  Assert.IsTrue( asJSONString = "{""1"":""hi"",""2"":""there""}" or asJSONString = "{""2"":""there"",""1"":""hi""}")
		  
		  Exception err as JSONException
		    Assert.Fail( "Could not handle Text" )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UnicodeTest()
		  dim j as new JSONItem
		  
		  j.Value( "a" + chr( 1 ) ) = "something" + chr( 2 )
		  Assert.AreSame( "{""a\u0001"":""something\u0002""}", j.ToString )
		  
		  j = new JSONItem
		  j.Append( "a" + chr( 1 ) )
		  Assert.AreSame( "[""a\u0001""]", j.ToString )
		  
		  dim highChar as string = Chr( &h10149 )
		  dim asEncoded as string = "[""\uD800\uDD49""]"
		  
		  j = new JSONItem( asEncoded )
		  Assert.AreEqual( EncodeHex( highChar, true ), EncodeHex( j( 0 ).StringValue, true ) )
		  
		  j = new JSONItem
		  try
		    j.Load( "[""\ujohn""]" )
		    Assert.Fail( "Loading '\ujohn' should have failed" )
		  catch err as JSONException
		  end
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
