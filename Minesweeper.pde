import de.bezier.guido.*;

boolean gameOver = false;
boolean gameWon = false;
float bombRatio = 0.15;
int NUM_ROWS = 20;
int NUM_COLS = 20;
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList<MSButton> mines = new ArrayList<MSButton>(); //ArrayList of just the minesweeper buttons that are mined

public void setup() {
    size(400, 400);
    textAlign(CENTER, CENTER);

    // make the manager
    Interactive.make(this);

    // Initialize buttons
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for (int i = 0; i < NUM_ROWS; i++) {
        for (int j = 0; j < NUM_COLS; j++) {
            buttons[i][j] = new MSButton(i, j);
        }
    }

    setMines();
}

public void setMines() {
    int totalSquares = NUM_ROWS * NUM_COLS;
    int numBombs = (int)(totalSquares * bombRatio);
    mines.clear();
    while (mines.size() < numBombs) {
        int randomRow = (int)(Math.random() * NUM_ROWS);
        int randomCol = (int)(Math.random() * NUM_COLS);
        if (!mines.contains(buttons[randomRow][randomCol])) {
            mines.add(buttons[randomRow][randomCol]);
        }
    }
}

public void draw() {
    background(0);
    if (isWon() == true) {
        displayWinningMessage();
    }
}

public boolean isWon() {
    for (int i = 0; i < buttons.length; i++) {
        for (int j = 0; j < buttons[i].length; j++) {
            if (buttons[i][j].getClickedVariable() == false && !mines.contains(buttons[i][j])) {
                return false;
            }
        }
    }
    return true;
}

public void displayLosingMessage() {
    gameOver = true;
    for (int i = 0; i < mines.size(); i++) {
        mines.get(i).setClickedVariable();
    }
    noLoop();
}

public void displayWinningMessage() {
    gameWon = true;
    noLoop();
}

public boolean isValid(int r, int c) {
    if (r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS) {
        return true;
    } else return false;
}

public int countMines(int row, int col) {
    int numMines = 0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if (i == 0 && j == 0) {
                continue;
            }
            if (isValid(row + i, col + j) && mines.contains(buttons[row + i][col + j])) {
                numMines++;
            }
        }
    }
    return numMines;
}

public class MSButton {
    private int myRow, myCol;
    private float x, y, width, height;
    private boolean clicked, flagged;
    private String myLabel;

    public MSButton(int row, int col) {
        width = 400 / NUM_COLS;
        height = 400 / NUM_ROWS;
        myRow = row;
        myCol = col;
        x = myCol * width;
        y = myRow * height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add(this); // register it with the manager
    }

    public void mousePressed() {
        if (gameOver) {
            return;
        }
        if (mouseButton == RIGHT) {
            flagged = !flagged;
            return;
        }

        clicked = true;

        if (mouseButton == LEFT && mines.contains(this)) {
            clicked = true;
            displayLosingMessage();
            return;
        } else if (mouseButton == LEFT && countMines(myRow, myCol) > 0) {
            clicked = true;
            setLabel(countMines(myRow, myCol));
            return;
        } else {
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    int row1 = myRow + i;
                    int col1 = myCol + j;
                    if (i == 0 && j == 0) {
                        continue;
                    } else if (isValid(row1, col1) && !buttons[row1][col1].getClickedVariable() && !mines.contains(buttons[row1][col1])) {
                        buttons[row1][col1].setClickedVariable();
                        if (countMines(row1, col1) == 0) {
                            buttons[row1][col1].mousePressed();
                        } else {
                            buttons[row1][col1].setLabel(countMines(row1, col1));
                        }
                    }
                }
            }
        }
    }

    public void draw() {
        if (flagged)
            fill(0);
        else if (clicked && mines.contains(this))
            fill(255, 0, 0);
        else if (clicked)
            fill(200);
        else
            fill(100);

        rect(x, y, width, height);
        fill(0);
        text(myLabel, x + width / 2, y + height / 2);

        if (gameOver) {
            fill(255, 0, 0);
            textSize(50);
            text("YOU LOSE!", 200, 200);
            textSize(10);
        }
        if (gameWon) {
            fill(0, 255, 0);
            textSize(50);
            text("YOU WIN!", 200, 200);
            textSize(10);
        }
    }

    public void setLabel(String newLabel) {
        myLabel = newLabel;
    }

    public void setLabel(int newLabel) {
        myLabel = "" + newLabel;
    }

    public boolean isFlagged() {
        return flagged;
    }

    public void setClickedVariable() {
        clicked = true;
    }

    public boolean getClickedVariable() {
        return clicked;
    }
}

public void keyPressed() {
    if (key == 'r' || key == 'R') {
        // Reset game
        gameOver = false;
        gameWon = false;

        // Recreate buttons for proper Interactive registration
        for (int i = 0; i < NUM_ROWS; i++) {
            for (int j = 0; j < NUM_COLS; j++) {
                buttons[i][j] = new MSButton(i, j);
            }
        }

        setMines();
        loop();
    }
}
