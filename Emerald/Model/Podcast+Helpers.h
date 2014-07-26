//
//  Podcast+Helpers.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/19/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "Podcast.h"

@interface Podcast (Helpers) <NSXMLParserDelegate>

- (NSArray *) fetchEpisodes;    // of Episode

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@end
