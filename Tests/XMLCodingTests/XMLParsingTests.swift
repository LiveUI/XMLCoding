import XCTest
@testable import XMLCoding

let LIST_XML = """
    <Response>
        <Result />
        <MetadataList>
            <item>
                <Id>id1</Id>
            </item>
            <item>
                <Id>id2</Id>
            </item>
            <item>
                <Id>id3</Id>
            </item>
        </MetadataList>
    </Response>
    """

let MAP_XML = """
    <Response>
        <Result />
        <MetadataMap>
            <item>
                <Key>key1</Key>
                <Value>value1</Value>
            </item>
            <item>
                <Key>key2</Key>
                <Value>value2</Value>
            </item>
            <item>
                <Key>key3</Key>
                <Value>value3</Value>
            </item>
        </MetadataMap>
    </Response>
    """

let SINGLETON_LIST_XML = """
    <Response>
        <Result />
        <MetadataList>
            <item>
                <Id>id1</Id>
            </item>
        </MetadataList>
    </Response>
    """

class XMLParsingTests: XCTestCase {
    struct Result: Codable, Equatable {
        let message: String?
        
        enum CodingKeys: String, CodingKey {
            case message = "Message"
        }
    }
    
    struct Metadata: Codable, Equatable {
        let id: String
        let optionalString: String?
        let data: Data?
        let date: Date?
        let bool: Bool?
        let int: Int?
        let double: Double?
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case optionalString = "OptionalString"
            case data = "Data"
            case date = "Date"
            case bool = "Bool"
            case int = "Int"
            case double = "Double"
        }
    }
    
    struct MapEntry: Codable, Equatable {
        let key: String
        let value: String

        
        enum CodingKeys: String, CodingKey {
            case key = "Key"
            case value = "Value"
        }
    }
    
    struct MetadataWithData: Codable, Equatable {
        let id: String
        let data: Data
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case data = "Data"
        }
    }
    
    struct MetadataList: Codable, Equatable {
        let items: [Metadata]
        
        enum CodingKeys: String, CodingKey {
            case items = "item"
        }
    }
    
    struct MetadataMap: Codable, Equatable {
        let items: [MapEntry]
        
        enum CodingKeys: String, CodingKey {
            case items = "item"
        }
    }
    
    struct MetadataWithCollapsedMap: Codable, Equatable {
        let items: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case items = "item"
        }
    }
    
    struct Response: Codable, Equatable {
        let result: Result
        let metadata: Metadata
        
        enum CodingKeys: String, CodingKey {
            case result = "Result"
            case metadata = "Metadata"
        }
    }
    
    struct ResponseWithData: Codable, Equatable {
        let result: Result
        let metadata: MetadataWithData
        
        enum CodingKeys: String, CodingKey {
            case result = "Result"
            case metadata = "Metadata"
        }
    }
    
    struct ResponseWithList: Codable, Equatable {
        let result: Result
        let metadataList: MetadataList
        
        enum CodingKeys: String, CodingKey {
            case result = "Result"
            case metadataList = "MetadataList"
        }
    }
    
    struct ResponseWithMap: Codable, Equatable {
        let result: Result
        let metadataMap: MetadataMap
        
        enum CodingKeys: String, CodingKey {
            case result = "Result"
            case metadataMap = "MetadataMap"
        }
    }
    
    struct ResponseWithCollapsedMap: Codable, Equatable {
        let result: Result
        let metadataMap: MetadataWithCollapsedMap
        
        enum CodingKeys: String, CodingKey {
            case result = "Result"
            case metadataMap = "MetadataMap"
        }
    }
    
    struct ResponseWithCollapsedListAndMap: Codable, Equatable {
        let result: Result
        let metadataMap: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case result = "Result"
            case metadataMap = "MetadataMap"
        }
    }
    
    struct ResponseWithCollapsedList: Codable, Equatable {
        let result: Result
        let metadataList: [Metadata]
        
        enum CodingKeys: String, CodingKey {
            case result = "Result"
            case metadataList = "MetadataList"
        }
    }
    
    /// Test that we can decode/encode fields of various types
    func testValuesElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>Hello</Message>
                </Result>
                <Metadata>
                    <Id>id</Id>
                    <Data>ZGF0YTE=</Data>
                    <Date>1534352914</Date>
                    <Bool>true</Bool>
                    <Int>77</Int>
                    <Double>45.345</Double>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(Response.self, from: inputData)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970 // to match decoder strategy
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(Response.self, from: data)
        XCTAssertEqual(response, response2)
        
        XCTAssertEqual("data1", String(data: response.metadata.data!, encoding: .utf8)) // decode the data
        XCTAssertEqual(Date(timeIntervalSince1970: 1534352914), response.metadata.date) // decode the date
        XCTAssertEqual(77, response.metadata.int) // decode the integer
        XCTAssertEqual(true, response.metadata.bool) // decode the boolean
        
        let double = response.metadata.double!
        XCTAssertTrue(double > 45 && double < 46)
    }
    
    /// Test that we can decode/encode required but empty string and data fields correctly
    func testEmptyValuesElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>Hello</Message>
                </Result>
                <Metadata>
                    <Id></Id>
                    <Data></Data>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(ResponseWithData.self, from: inputData)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970 // to match decoder strategy
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(ResponseWithData.self, from: data)
        XCTAssertEqual(response, response2)
        
        // has a zero length string
        XCTAssertEqual(0, response.metadata.id.count)
        // has a zero length data
        XCTAssertEqual(0, response.metadata.data.count)
    }
    
    /// Test that we only substitute an empty string if the field is present
    func testFailOnMissingStringElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>Hello</Message>
                </Result>
                <Metadata>
                    <Data></Data>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        do {
            _ = try XMLDecoder().decode(ResponseWithData.self, from: inputData)
        } catch {
            return
        }
        
        XCTFail("Decoding should have failed")
    }
    
    /// Test that we only substitute an empty data if the field is present
    func testFailOnMissingDataElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>Hello</Message>
                </Result>
                <Metadata>
                    <Id></Id>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        do {
            _ = try XMLDecoder().decode(ResponseWithData.self, from: inputData)
        } catch {
            return
        }
        
        XCTFail("Decoding should have failed")
    }
    
    /// Test that we can decode/encode empty optional fields correctly as nil optionals
    func testOptionalEmptyValuesElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>Hello</Message>
                </Result>
                <Metadata>
                    <Id>id</Id>
                    <OptionalString></OptionalString>
                    <Data></Data>
                    <Date></Date>
                    <Bool></Bool>
                    <Int></Int>
                    <Double></Double>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(Response.self, from: inputData)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970 // to match decoder strategy
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(Response.self, from: data)
        XCTAssertEqual(response, response2)
        
        XCTAssertNil(response.metadata.optionalString) // the OptionalString tag is empty and optional
        XCTAssertNil(response.metadata.data) // the Data tag is empty and optional
        XCTAssertNil(response.metadata.date) // the Date tag is empty and optional
        XCTAssertNil(response.metadata.bool) // the Bool tag is empty and optional
        XCTAssertNil(response.metadata.int) // the Int tag is empty and optional
        XCTAssertNil(response.metadata.double) // the Double tag is empty and optional
    }
    
    /// Test that we can decode/encode missing optional fields correctly as nil optionals
    func testOptionalMissingValuesElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>Hello</Message>
                </Result>
                <Metadata>
                    <Id>id</Id>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(Response.self, from: inputData)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970 // to match decoder strategy
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(Response.self, from: data)
        XCTAssertEqual(response, response2)
        
        XCTAssertNil(response.metadata.optionalString) // the OptionalString tag is empty and optional
        XCTAssertNil(response.metadata.data) // the Data tag is empty and optional
        XCTAssertNil(response.metadata.date) // the Date tag is empty and optional
        XCTAssertNil(response.metadata.bool) // the Bool tag is empty and optional
        XCTAssertNil(response.metadata.double) // the Double tag is empty and optional
    }
    
    /// Test that we can decode/encode empty single-tag optional fields correctly as nil optionals
    func testOptionalEmptyValuesCombinedTagElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>Hello</Message>
                </Result>
                <Metadata>
                    <Id>id</Id>
                    <OptionalString />
                    <Data />
                    <Date />
                    <Bool />
                    <Int />
                    <Double />
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(Response.self, from: inputData)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970 // to match decoder strategy
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(Response.self, from: data)
        XCTAssertEqual(response, response2)
        
        XCTAssertNil(response.metadata.optionalString) // the OptionalString tag is empty and optional
        XCTAssertNil(response.metadata.data) // the Data tag is empty and optional
        XCTAssertNil(response.metadata.date) // the Date tag is empty and optional
        XCTAssertNil(response.metadata.bool) // the Bool tag is empty and optional
        XCTAssertNil(response.metadata.int) // the Int tag is empty and optional
        XCTAssertNil(response.metadata.double) // the Double tag is empty and optional
    }
    
    /// Test that we can decode/encode ISO8601 dates correctly
    func testValuesWithISO8601DateElement() throws {
        if #available(OSX 10.12, *) {
            let inputString = """
                <Response>
                    <Result>
                        <Message>Hello</Message>
                    </Result>
                    <Metadata>
                        <Id>id</Id>
                        <Data>ZGF0YTE=</Data>
                        <Date>2018-08-15T10:08:34-07:00</Date>
                        <Bool>true</Bool>
                        <Double>45.345</Double>
                    </Metadata>
                </Response>
                """
            
            guard let inputData = inputString.data(using: .utf8) else {
                return XCTFail()
            }
            
            let decoder = XMLDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(Response.self, from: inputData)
            
            // encode the output to make sure we get what we started with
            let encoder = XMLEncoder()
            encoder.dateEncodingStrategy = .iso8601 // to match decoder strategy
            let data = try encoder.encode(response, withRootKey: "Response")
            
            let response2 = try decoder.decode(Response.self, from: data)
            XCTAssertEqual(response, response2)
            
            XCTAssertEqual("data1", String(data: response.metadata.data!, encoding: .utf8)) // decode the data
            XCTAssertEqual(Date(timeIntervalSince1970: 1534352914), response.metadata.date) // decode the date
            XCTAssertEqual(true, response.metadata.bool) // decode the boolean
            
            let double = response.metadata.double!
            XCTAssertTrue(double > 45 && double < 46)
        }
    }
    
    /// Test that we can decode/encode empty structures correctly
    func testEmptyStructureElement() throws {
        let inputString = """
            <Response>
                <Result/>
                <Metadata>
                    <Id>id</Id>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(Response.self, from: inputData)
        
        XCTAssertNil(response.result.message)
    }

    /// Test that we can decode/encode multiple empty structures without a later one wiping out the former
    func testEmptyStructureElementNotEffectingPreviousElement() throws {
        let inputString = """
            <Response>
                <Result>
                    <Message>message</Message>
                </Result>
                <Result/>
                <Metadata>
                    <Id>id</Id>
                </Metadata>
            </Response>
            """
        
        guard let inputData = inputString.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(Response.self, from: inputData)
        
        XCTAssertEqual("message", response.result.message)
    }
    
    /// Test that we can decode/encode lists with the default strategy
    func testListDecodingWithDefaultStrategy() throws {
        guard let inputData = LIST_XML.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(ResponseWithList.self, from: inputData)
        
        XCTAssertEqual(3, response.metadataList.items.count)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(ResponseWithList.self, from: data)
        XCTAssertEqual(response, response2)
    }
    
    /// Test that we can decode/encode maps with the default strategy
    func testMapDecodingWithDefaultStrategy() throws {
        guard let inputData = MAP_XML.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(ResponseWithMap.self, from: inputData)
        
        XCTAssertEqual(3, response.metadataMap.items.count)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(ResponseWithMap.self, from: data)
        XCTAssertEqual(response, response2)
    }
    
    /// Test that we can decode/encode maps with collapsed maps
    func testMapDecodingWithCollapsedMap() throws {
        guard let inputData = MAP_XML.data(using: .utf8) else {
            return XCTFail()
        }
        
        let decoder = XMLDecoder()
        decoder.mapDecodingStrategy = .collapseMapUsingTags(keyTag: "Key", valueTag: "Value")
        let response = try! decoder.decode(ResponseWithCollapsedMap.self, from: inputData)
        
        XCTAssertEqual(3, response.metadataMap.items.count)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        encoder.mapEncodingStrategy = .expandMapUsingTags(keyTag: "Key", valueTag: "Value")
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try decoder.decode(ResponseWithCollapsedMap.self, from: data)
        XCTAssertEqual(response, response2)
    }
    
    /// Test that we can decode/encode maps with collapsed lists and maps
    func testMapDecodingWithCollapsedListAndMap() throws {
        guard let inputData = MAP_XML.data(using: .utf8) else {
            return XCTFail()
        }
        
        let decoder = XMLDecoder()
        decoder.mapDecodingStrategy = .collapseMapUsingTags(keyTag: "Key", valueTag: "Value")
        decoder.listDecodingStrategy = .collapseListUsingItemTag("item")
        let response = try! decoder.decode(ResponseWithCollapsedListAndMap.self, from: inputData)
        
        XCTAssertEqual(3, response.metadataMap.count)
        
        // encode the output to make sure we get what we started with
        let encoder = XMLEncoder()
        encoder.mapEncodingStrategy = .expandMapUsingTags(keyTag: "Key", valueTag: "Value")
        encoder.listEncodingStrategy = .expandListWithItemTag("item")
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try decoder.decode(ResponseWithCollapsedListAndMap.self, from: data)
        XCTAssertEqual(response, response2)
    }
    
    /// Test that we can decode/encode single element lists with the default strategy
    func testSingletonListDecodingWithDefaultStrategy() throws {
        guard let inputData = SINGLETON_LIST_XML.data(using: .utf8) else {
            return XCTFail()
        }
        
        let response = try XMLDecoder().decode(ResponseWithList.self, from: inputData)
        
        XCTAssertEqual(1, response.metadataList.items.count)
        
        // encode the output to make sure we get what we started with
        let data = try XMLEncoder().encode(response, withRootKey: "Response")
        
        let response2 = try XMLDecoder().decode(ResponseWithList.self, from: data)
        XCTAssertEqual(response, response2)
    }
    
    /// Test that we can decode/encode lists with the collapsing strategy
    func testListDecodingWithCollapseItemTagStrategy() throws {
        guard let inputData = LIST_XML.data(using: .utf8) else {
            return XCTFail()
        }
        
        let decoder = XMLDecoder()
        decoder.listDecodingStrategy = .collapseListUsingItemTag("item")
        let response = try decoder.decode(ResponseWithCollapsedList.self, from: inputData)
        
        XCTAssertEqual(3, response.metadataList.count)
        
        let encoder = XMLEncoder()
        encoder.listEncodingStrategy = .expandListWithItemTag("item")
        
        // encode the output to make sure we get what we started with
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try decoder.decode(ResponseWithCollapsedList.self, from: data)
        XCTAssertEqual(response, response2)
    }
    
    /// Test that we can decode/encode single element lists with the collapsing strategy
    func testSingletonListDecodingWithCollapseItemTagStrategy() throws {
        guard let inputData = SINGLETON_LIST_XML.data(using: .utf8) else {
            return XCTFail()
        }
        
        let decoder = XMLDecoder()
        decoder.listDecodingStrategy = .collapseListUsingItemTag("item")
        let response = try decoder.decode(ResponseWithCollapsedList.self, from: inputData)
        
        XCTAssertEqual(1, response.metadataList.count)
        
        let encoder = XMLEncoder()
        encoder.listEncodingStrategy = .expandListWithItemTag("item")
        
        // encode the output to make sure we get what we started with
        let data = try encoder.encode(response, withRootKey: "Response")
        
        let response2 = try decoder.decode(ResponseWithCollapsedList.self, from: data)
        XCTAssertEqual(response, response2)
    }

    // Tests discovered automatically
}
