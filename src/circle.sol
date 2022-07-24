// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/utils/Strings.sol";

contract Circle {
    // Used constants and their values: Image width ( W = 600 ), Image height ( H = 600 ), Number of “static” circles ( NSC = 4 ), Number of “dynamic” circles ( NDC = 5 ), Distance between “static” circles ( SD = 45 ), Distance between “dynamic” circles ( DD = 6 ), Number of bits per circle ( BPC = 10 ).
    uint256 W = 600;
    uint256 H = 600;
    uint256 NSC = 4 ;
    uint256 NDC = 5 ;
    uint256 SD = 45;
    uint256 DD = 6;
    uint256 BPC = 10;




    function _createSVG(string memory body) internal view returns (string memory svgElement) {
        svgElement =  string.concat('<svg xmlns="http://www.w3.org/2000/svg" ',
                               'width="', Strings.toString(W),
                               '" height="', Strings.toString(H), '"> <g> ',
                               body, '</g> </svg> '
                       );
    }
    
    function _createCircle (uint cx, uint cy, uint r, string memory fill, string memory stroke, string memory body) internal pure returns (string memory svgElement) {
        svgElement = string.concat('<circle ',
                       'cx ="', Strings.toString(cx), '" ',
                       'cy="', Strings.toString(cy), '" ',
                       'r="', Strings.toString(r), '" ',
                       'fill="', fill, '" ',
                       'stroke="', stroke, '"> ', body, '</circle> '
                   );
    }
    
    function _createAnimation
       (uint cx, uint cy, uint r)
       internal pure
       returns (string memory){

       return string.concat(
           '<animateTransform attributeName="transform" attributeType="XML" type="rotate" ',
           'from="0 ', string.concat(Strings.toString(cx), ' ', Strings.toString(cy), '" '),
           'to="360 ', string.concat(Strings.toString(cx), ' ', Strings.toString(cy), '" '),
           'dur="', Strings.toString(2+r), '" ', 'repeatCount="indefinite"/> '
       );
    }
    function _extractCircle
   (uint seed, uint idx)
   internal view
   returns (uint extractedCircle){

   extractedCircle = (seed >>  (idx*BPC)) & ((2 << BPC) - 1);
}

function _unpackCircle
   (uint seed, uint idx)
   internal view returns
   (uint cx, uint cy, uint r, string memory fill, string memory stroke) {

   uint packedCircle = (seed >>  (idx*BPC)) & ((2 << BPC) - 1);
   cx = 1 + (packedCircle & 3);
   cy = 1 + ((packedCircle >>  2) & 3);
   r = 1 + ((packedCircle >>  4) & 3);
   fill = "FF160C";
   stroke = "0096FF";
//    fill = _getColor((packedCircle >>  6 ) & 3);
//    stroke = _getColor((packedCircle >>  8 ) & 3);
}

// function _getColor(uint x) internal returns (string memory) {
    
// }

function _render
   (uint seed)
   public
   returns (string memory svg){

   svg = _createSVG(string.concat(
       _buildStaticPart(seed),
       _buildDynamicPart(seed)
   ));
}

function _buildStaticPart
   (uint seed)
   internal view
   returns (string memory svgPart){

   for(uint idx = 0; idx < NSC; ++idx){

       (, , , string memory fill, string memory stroke) = _unpackCircle(seed, idx);

       svgPart = string.concat(svgPart, _createCircle(
           W/2, H/2, (NSC-idx)*SD, fill, stroke, "")
       );
   }
}

function _buildDynamicPart
   (uint seed)
   internal view
   returns (string memory svgPart){
  
   for(uint idx = NSC; idx < NSC + (NSC-1)*NDC; idx += NDC){

       (uint cx, uint cy, uint r, , ) = _unpackCircle(seed, idx);

       svgPart = string.concat(svgPart,_createSVG(string.concat(
           _createAnimation(W/2, H/2, cx*cy+r+idx),
           _buildDynamicSubPart(seed, idx, SD*(1+idx/NSC)))
       ));
      
   }
}

function _buildDynamicSubPart
   (uint seed, uint idx, uint cdist)
   internal view
   returns (string memory svgPart){

   for(uint jdx = 0; jdx < (NDC-1)/2 + 1; ++jdx){

       (, , , string memory fill, string memory stroke) = _unpackCircle(seed, idx++);

       svgPart = string.concat(svgPart,
           _createCircle(
               W/2-cdist, H/2, (1+jdx)*DD, fill, stroke, "")
       );
       svgPart = string.concat(svgPart,
           _createCircle(
               W/2+cdist, H/2, (1+jdx)*DD, fill, stroke, "")
       );
   }

   for(uint rdx = (NDC-1)/2 + 1; rdx < NDC; ++rdx){

       (uint cx, , uint r, string memory fill, string memory stroke) = _unpackCircle(seed, idx++);

       svgPart = string.concat(svgPart,
           _createCircle(W/2-cdist-((rdx-(NDC-1)/2+1)*DD), H/2, r, fill, stroke,
               _createAnimation(W/2-cdist, H/2, r+cx)),
           _createCircle(W/2+cdist+((rdx-(NDC-1)/2+1)*DD), H/2, r, fill, stroke,
               _createAnimation(W/2+cdist, H/2, r+cx))
       );
   }
}
}