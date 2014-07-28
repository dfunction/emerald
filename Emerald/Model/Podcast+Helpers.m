//
//  Podcast+Helpers.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/19/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "Podcast+Helpers.h"
#import "Episode+Helpers.h"

@implementation Podcast (Helpers)

Episode *currentEpisode;
NSMutableString *currentString;
NSMutableArray* temporaryEpisodes;


- (NSArray *) fetchEpisodes // of Episode
{
    NSURL* url = [NSURL URLWithString:[self url]];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    temporaryEpisodes = [[NSMutableArray alloc] init];
    NSArray* currentEpisodes = [[self episodes] allObjects];
    for (NSUInteger i = 0; i < [temporaryEpisodes count]; i++) {
        BOOL alreadyExists = NO;
        for (NSUInteger j = 0; j < [currentEpisodes count]; j++) {
            if ([((Episode*)temporaryEpisodes[i]).url isEqualToString:((Episode*)currentEpisodes[j]).url])
                alreadyExists = YES;
        }
        if (!alreadyExists) {
            [self addEpisodesObject:temporaryEpisodes[i]];
            [[self managedObjectContext] save:NULL];
        }
    }
    
    NSArray* episodes = [[self episodes] allObjects];
    [episodes sortedArrayUsingSelector:(@selector(dateCompare:))];
    temporaryEpisodes = NULL;
    return episodes;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"]) {
        if (currentEpisode.url != NULL) {
            [temporaryEpisodes addObject:currentEpisode];
        }
        currentEpisode = NULL;
    } else if ([elementName isEqualToString:@"title"]) {
        if (currentEpisode != NULL) {
            [currentEpisode setTitle:currentString];
            currentString = NULL;
        }
    } else if ([elementName isEqualToString:@"pubDate"]) {
        if (currentEpisode != NULL) {
            [currentEpisode setDate:currentString];
            currentString = NULL;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"]) {
        Episode *episode = [[Episode alloc] initWithEntity:[NSEntityDescription entityForName:@"Episode" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:[self managedObjectContext]];
        currentEpisode = episode;
    } else if ([elementName isEqualToString:@"media:content"]) {
        [currentEpisode setUrl:[attributeDict valueForKeyPath:@"url"]];
    } else if ([elementName isEqualToString:@"media:thumbnail"]) {
        [currentEpisode setImageUrl:[attributeDict valueForKeyPath:@"url"]];
    }else if ([elementName isEqualToString:@"title"]){
        currentString = [[NSMutableString alloc] initWithString:@""];
    } else if ([elementName isEqualToString:@"pubDate"]){
        currentString = [[NSMutableString alloc] initWithString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentString) [currentString appendString:string];
}

@end
