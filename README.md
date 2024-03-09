# Screenshotmaker
This is a screenshot maker for the game Simutrans using a shell script to achieve higher resolution bigger screenshots of an area the user wants to screenshot.

WARNING: It only works with builds of Simutrans that can be opened in the command line with at a specific coordinate in the map (like can be done in [teamhimeh/simutrans's OTRP branch](https://github.com/teamhimeh/simutrans)
WARNING: It only has been tested on Windows using WSL, so it should also work on Linux but this hasn't been tested 

requirements:
- imagemagick version 6

WARNING: If the area selected is too big, the `/etc/ImageMagick-6/policy.xml` file has to be changed in order for the script to have sufficient allocated resources.

There are still some major bugs in the script but it works for now.
Bugs:
- Can't screenshot an area that would include the outside of the map (coordinates in the negative and outside the size of the Simutrans map)
- Can't deal with different zoom levels (assumes standard zoom)
- Area selected should be more than what the user wants to screenshot

```
usage: ./run.sh <PATH EXE> <PAKSET NAME> <SAVEFILE> <POS1> <POS2> <SCREENSHOTS LOCATION> <PAKSET SIZE> <OUTPUT NAME>
  PATH EXE              - path to Simutrans exe
  PAKSET NAME           - name of pakset
  SAVEFILE              - name of savefile
  POS1/POS2             - position of the area to be screenshotted
  SCREENSHOTS LOCATION  - location Simutrans saves screenshots
  PAKSET SIZE           - pakset size
  OUTPUT NAME           - name of the resulting image
```
