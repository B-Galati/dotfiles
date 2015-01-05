<?php

#if (${NAMESPACE})
namespace ${NAMESPACE};
#end

/**
 * ${NAME}
 *
 * @package ${NAMESPACE}
 */
class ${NAME} extends#if(${NAMESPACE}) \PHPUnit_Framework_TestCase #else PHPUnit_Framework_TestCase #end
{

}
