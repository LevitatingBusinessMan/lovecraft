#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <fcntl.h>
#include <errno.h>

#define STORYFOLDER_PATH "stories"
#define DEBUG 0
#define MIN_PAR_LENGTH 200
#define MAX_PAR_LENGTH 3000
#define SHOW_DETAILS 1

typedef struct StoryNode {
	char* filename;
	struct StoryNode* next;
} StoryNode;

typedef struct Paragraph {
	int begin;
	int end;
} Paragraph;

int main(int argc, char *argv []) {

	DIR *storyfolder;
	if (!(storyfolder = opendir(STORYFOLDER_PATH))) {
		perror("Error opening stories directory");
		return errno;
	}

	int storycount = 0;

	struct StoryNode *firstStory;
	struct StoryNode *previousStory;

	struct dirent *story_entry;
	while ((story_entry=readdir(storyfolder))) {
		//Ignore . and ..
		if (strcmp(story_entry->d_name, ".") == 0 || strcmp(story_entry->d_name, "..") == 0) {
			continue;
		}

		storycount++;
		if (DEBUG) {
			printf("Found story: %s\n", story_entry->d_name);
		}

		if (storycount == 1) {
			firstStory = malloc(sizeof(StoryNode));
			firstStory->filename = story_entry->d_name;
			previousStory = firstStory;
		} else {
			struct StoryNode *Node = malloc(sizeof(StoryNode));
			Node->filename = story_entry->d_name;
			previousStory->next = Node;
			previousStory = Node;
		}
	}

	srand(time(NULL));

	int random_index = (rand() % (storycount));

	struct StoryNode *currentNode = firstStory;
	for (int i=0; i<random_index; i++) {
		currentNode = currentNode->next;
	}

	char* storyfilename = currentNode->filename;

	if (DEBUG) printf("Random story: %s\n", storyfilename);

	FILE *storyfile;
	//This expression might seem ineffecient but thats because it is
	//It stays for now, will use fopen with a concatenated string in the future
	if ((storyfile = fdopen(openat(dirfd(storyfolder), storyfilename, O_RDONLY), "r")) < 0) {
		perror("Error opening file");
		return errno;
	};

	int c;
	int index = 0;
	int last_newline = 0;

	struct Paragraph paragraphs[256];
	int pr_index = 0;

	while ((c = fgetc(storyfile)) != EOF) {
		if (c != '\n') {
			index++;
			continue;
		}
		
		int length = index - last_newline;
		if (length > MIN_PAR_LENGTH && length < MAX_PAR_LENGTH) {
			struct Paragraph new_par;
			//This points to the first char of the paragraph, starting from index 1
			new_par.begin = last_newline == 0 ? last_newline+1 : last_newline+2;
			new_par.end = index;

			paragraphs[pr_index] = new_par;
			pr_index++;
		}
		last_newline = index;
		index++;
	}

	random_index = (rand() % (pr_index));
	if (DEBUG) printf("Random paragraph: %d\n", random_index);

	struct Paragraph paragraph = paragraphs[random_index];

	char *paragraph_str = malloc(paragraph.end - paragraph.begin +1);

	index = 1;
	int str_index = 0;
	rewind(storyfile);
	//Read the file again, but this time save the random paragraph
	while ((c = fgetc(storyfile)) != EOF) {
		if (index > paragraph.end) break;
		if (index >= paragraph.begin) {
			paragraph_str[str_index] = c;
			str_index++;
		}
		index++;
	}
	paragraph_str[str_index] = '\0';

	if (SHOW_DETAILS) {
		//I use \b to remove the ".txt"
		printf("%s\n\n~ %s\b\b\b\b (%d:%d)\n", paragraph_str, storyfilename, paragraph.begin, paragraph.end);
	} else {
		printf("%s\n", paragraph_str);
	}

}
