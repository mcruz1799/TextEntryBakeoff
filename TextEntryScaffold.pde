import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 120; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PImage finger;

//Variables for my silly implementation. You can delete this:

int vowelTextSize = 20; //size of vowel in the center of the button
int consonantTextSize = 12; //size of the consonant in the corners of the button

int[] vowelSquareColor = {0,0,200};
int[] vowelTextColor = {255,255,255};

int[] consonantSquareColor = {0,255,0};
int[] consonantTextColor = {200,200,200};

int numRows = 2;
int numCols = 3;
float vowelSquareWidth = sizeOfInputArea/numCols;
float vowelSquareHeight = sizeOfInputArea/numRows;

float consonantSquareWidth = vowelSquareWidth/2;
float consonantSquareHeight = vowelSquareHeight/3;

float xpadding = 8;
float ypadding = 12;

float yOffset = 5;
boolean isDragging;



float consonantWidth = sizeOfInputArea/3;
float consonantHeight = sizeOfInputArea/3;

char currentLetter = ' ';
VowelSquare currVowel;


ArrayList<VowelSquare> vowelSquares;
class VowelSquare {
  String letters;
  float x; 
  float y; 
  ArrayList <ConsonantSquare> consonantSquares;
  VowelSquare(String _letters, float _x, float _y) {
    letters = _letters; 
    x = _x;
    y = _y;
    consonantSquares = new ArrayList<ConsonantSquare>();
  }
  
}

class ConsonantSquare {
  char consonant;
  float x;
  float y;
  String pos;
  ConsonantSquare(char _consonant, float _x, float _y, String _pos){
    consonant = _consonant;
    x = _x;
    y = _y;
    pos = _pos;
  }
}






//You can modify anything in here. This is just a basic implementation.
void setup()
{
  noCursor();
  watch = loadImage("watchhand3smaller.png");
  finger = loadImage("pngeggSmaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  
  initializeVowelSquares(); //sets up vowel squares and consonant squares with appropriate values
  

  
}

void initializeVowelSquares(){
  //initialize vowel squares
  vowelSquares = new ArrayList<VowelSquare>();

  //initial x and y for first vs
  float buttonX = width/2 - sizeOfInputArea/2 + vowelSquareWidth/2;
  float buttonY = height/2 - sizeOfInputArea/2 + vowelSquareHeight/2;
  //create array list of all the letters separated by button
  ArrayList<String> alphabetList = new ArrayList<String>();
    alphabetList.add("abcd");
    alphabetList.add("efgh");
    alphabetList.add("ijklmn");
    alphabetList.add("opqrst");
    alphabetList.add("uvwx");
    alphabetList.add("yz<_");
  //loop that initializes the squares with their appropriate positions into the vowelSquares ArrayList
  int count = 0;
  for (int i = 0; i < numRows; i++){
    for (int j = 0; j < numCols; j++){
      VowelSquare newVS = new VowelSquare(alphabetList.get(count), 
                                          buttonX + vowelSquareWidth * j, 
                                          buttonY + vowelSquareHeight * i);
      vowelSquares.add(newVS);
      System.out.println("VowelSquare: " + newVS.letters.charAt(0) + " (" + newVS.x + ", " + newVS.y + ")");
      String consonants = newVS.letters.substring(1);
      if (consonants.length() == 3) initialize3ConsonantSquares(newVS, consonants,xpadding, ypadding);
      else initialize5ConsonantSquares(newVS, consonants, xpadding, ypadding);
      
      count++;
    }
  }
}

void initialize3ConsonantSquares(VowelSquare vs, String letters, float xpadding, float ypadding){
  //draw consonants
  //topleft
  float tlX = vs.x - vowelSquareWidth/2 + consonantSquareWidth/2;
  float tlY = vs.y - vowelSquareHeight/2 + consonantSquareHeight/2;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(0), tlX, tlY, "tl"));
  //topRight
  float trX = vs.x + vowelSquareWidth/2 - consonantSquareWidth/2;
  float trY = vs.y - vowelSquareHeight/2 + consonantSquareHeight/2;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(1), trX, trY, "tr"));
  //bottomRight
  float brX = vs.x + vowelSquareWidth/2 - consonantSquareWidth/2;
  float brY = vs.y + vowelSquareHeight/2 - consonantSquareHeight/2;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(2), brX, brY, "br"));
}

void initialize5ConsonantSquares(VowelSquare vs, String letters, float xpadding, float ypadding){
  //topleft
  float tlX = vs.x - vowelSquareWidth/2 + consonantSquareWidth/2;
  float tlY = vs.y - vowelSquareHeight/2 + consonantSquareHeight/2;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(0), tlX, tlY, "tl"));
  //topRight
  float trX = vs.x + vowelSquareWidth/2 - consonantSquareWidth/2;
  float trY = vs.y - vowelSquareHeight/2 + consonantSquareHeight/2;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(1), trX, trY, "tr"));
  //middleRight
  float mrX = vs.x + vowelSquareWidth/2 - consonantSquareWidth/2;
  float mrY = vs.y;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(2), mrX, mrY, "mr"));
  //bottomRight
  float brX = vs.x + vowelSquareWidth/2 - consonantSquareWidth/2;
  float brY = vs.y + vowelSquareHeight/2 - consonantSquareHeight/2;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(3), brX, brY, "br"));
  //bottomLeft
  float blX = vs.x - vowelSquareWidth/2 + consonantSquareWidth/2;
  float blY = vs.y + vowelSquareHeight/2 - consonantSquareHeight/2;
  vs.consonantSquares.add(new ConsonantSquare(letters.charAt(4), blX, blY, "bl"));
}

void drawSquare(char letter, int[] squareColor, float x, float y, float w, float h, int textSize, int[] textColor){
  //draw square
  if (textSize == vowelTextSize){
    fill(squareColor[0],squareColor[1],squareColor[2]);
    stroke(0,0,0);
    rectMode(CENTER);
    rect(x,y,w,h);
  }
  //draw letter
  rectMode(CENTER);
  textSize(textSize);
  fill(textColor[0],textColor[1],textColor[2]);
  text(letter, x, y + yOffset);
  
}

void drawOverlay(VowelSquare vs){

  //for expanded vowel square functions
  float leftX = width/2 - sizeOfInputArea/2;
  float rightX = width/2 + sizeOfInputArea/2 - consonantWidth;
  float topY = height/2 - sizeOfInputArea/2;
  float bottomY = height/2 + sizeOfInputArea/2 - consonantHeight;
  
  char vowel = vs.letters.charAt(0);
  if (vowel == currentLetter){
    fill(0,0,200);
  }
  else{
    fill(0,0,150);
  }
  rect(leftX, topY, sizeOfInputArea, sizeOfInputArea);
  textSize(60); 
  fill(vowelTextColor[0], vowelTextColor[1], vowelTextColor[2]);
  text(vowel, width/2, height/2 + 10);
  
  textSize(20);
  float yPadding = 5;

  //System.out.println(String.format("height/2=%s; width/2=%s", height/2, width/2));
  //System.out.println(String.format("leftX=%s; rightX = %s; topY = %s; bottomY = %s", leftX, rightX, topY, bottomY));
  for (ConsonantSquare cs: vs.consonantSquares){
    rectMode(CORNER);
    textAlign(CENTER);
    if (cs.consonant == currentLetter){
      fill(200,200,200);
    }
    else {
      fill(100,100,100);
    }
    stroke(0,0,0);
    switch (cs.pos){
      case "tl":
        
        rect(leftX, topY, consonantWidth, consonantHeight);
        fill(255,255,255);
        text(cs.consonant, leftX + consonantWidth/2, topY + consonantHeight/2 + yPadding);
        break;
      case "tr":
        
        rect(rightX, topY, consonantWidth, consonantHeight);
        fill(255,255,255);
        text(cs.consonant, rightX + consonantWidth/2, topY + consonantHeight/2 + yPadding);
        break;
      case "mr":

        rect(rightX, height/2-consonantWidth/2, consonantWidth, consonantHeight);
        fill(255,255,255);
        text(cs.consonant, rightX + consonantWidth/2, height/2 + yPadding);
        break;
      case "br":
        
        rect(rightX, bottomY, consonantWidth, consonantHeight);
        fill(255,255,255);
        text(cs.consonant, rightX + consonantWidth/2, bottomY + consonantHeight/2 + yPadding);
        break;
      case "bl":
        
        rect(leftX, bottomY, consonantWidth, consonantHeight);
        fill(255,255,255);
        text(cs.consonant, leftX + consonantWidth/2, bottomY + consonantHeight/2 + yPadding);
        break;
    }
  }
  
  
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  
  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    textSize(24);
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

  }
  textAlign(CENTER);
  
  if (mousePressed){
    if (currVowel != null){
      drawOverlay(currVowel);
    }
  }
  
  else{
      for (VowelSquare vs: vowelSquares){
        drawSquare(vs.letters.charAt(0), vowelSquareColor, vs.x, vs.y, vowelSquareWidth, vowelSquareHeight, vowelTextSize, vowelTextColor);
      }
      for (VowelSquare vs: vowelSquares){
        for (ConsonantSquare cs: vs.consonantSquares){
          drawSquare(cs.consonant, consonantSquareColor, cs.x, cs.y, consonantSquareWidth, consonantSquareHeight, consonantTextSize, consonantTextColor);
        }
      }
  
  }
  
  
  
  
  drawFinger(); //this is your "cursor"
  

  
}


boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


//my terrible implementation you can entirely replace
void mousePressed()
{
  //if mouse clicked vowelSquare
  for (VowelSquare vs: vowelSquares){
    if (didMouseClick(vs.x-vowelSquareWidth/2, vs.y-vowelSquareHeight/2, vowelSquareWidth, vowelSquareHeight)){
      System.out.println("DRAGGING ON VOWEL: " + vs.letters.charAt(0));
      isDragging = true;
      currVowel = vs;
    }
  }
  
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void mouseDragged()
{

  if (isDragging && currVowel != null)
  {
    float leftX = width/2 - sizeOfInputArea/2;
    float rightX = width/2 + sizeOfInputArea/2 - consonantWidth;
    float topY = height/2 - sizeOfInputArea/2;
    float bottomY = height/2 + sizeOfInputArea/2 - consonantHeight;
    boolean inputChosen = false;
    for (ConsonantSquare cs: currVowel.consonantSquares){
      float x = 0;
      float y = 0;
      switch(cs.pos){
        case "tl":
          x = leftX; y = topY;
          break;
        case "tr":
          x = rightX; y = topY;
          break;
        case "mr":
          x = rightX; y = height/2;
          break;
        case "br":
          x = rightX; y = bottomY;
          break;
        case "bl":
          x = leftX; y = bottomY;
          break;
      }
      System.out.println(String.format("consonant=%s, x=%s, y=%s, w=%s, height=%s", cs.consonant, x, y, consonantWidth,consonantHeight));
      System.out.println("within? " + didMouseClick(x,y,consonantWidth,consonantHeight));
      if (didMouseClick(x, y, consonantWidth, consonantHeight)){
        System.out.println("currentLetter = " + cs.consonant);
        currentLetter = cs.consonant;
        inputChosen = true;
        break;
      }
    }
    if (inputChosen == false){
      System.out.println("currentLetter = " + currVowel.letters.charAt(0));
      currentLetter = currVowel.letters.charAt(0);
    }
  //  isDragging = false;
  //  currVowel = null;
  }
}

void mouseReleased()
{
  if (isDragging && currVowel != null)
  {
    float leftX = width/2 - sizeOfInputArea/2;
    float rightX = width/2 + sizeOfInputArea/2 - consonantWidth;
    float topY = height/2 - sizeOfInputArea/2;
    float bottomY = height/2 + sizeOfInputArea/2 - consonantHeight;

    boolean inputChosen = false;
    for (ConsonantSquare cs: currVowel.consonantSquares){
      float x = 0;
      float y = 0;
      switch(cs.pos){
        case "tl":
          x = leftX; y = topY;
          break;
        case "tr":
          x = rightX; y = topY;
          break;
        case "mr":
          x = rightX; y = height/2;
          break;
        case "br":
          x = rightX; y = bottomY;
          break;
        case "bl":
          x = leftX; y = bottomY;
          break;
      } 
      if (checkIfLetterClicked(cs.consonant, x, y, consonantWidth, consonantHeight)){
        inputChosen = true;
        break;
      }
    }
    if (inputChosen == false){
      currentTyped += currVowel.letters.charAt(0);
    }
    isDragging = false;
    currVowel = null;
    currentLetter = ' ';
  }
}

boolean checkIfLetterClicked(char letter, float x, float y, float w, float h){
  if (didMouseClick(x,y,w,h)){
    if (letter == '_'){
      currentTyped += " ";
    }
    else if (letter == '<'){
      if (currentTyped.length() > 0){
        currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
      }
    }
    else{
      currentTyped += letter;
    }
    return true;
  }
  return false;
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger,52,341);
  if (mousePressed)
     fill(0);
  else
     fill(255);
  ellipse(0,0,5,5);

  popMatrix();
  }
  

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
