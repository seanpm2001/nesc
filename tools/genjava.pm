# This file is part of the nesC compiler.
#    Copyright (C) 2002 Intel Corporation
# 
# The attached "nesC" software is provided to you under the terms and
# conditions of the GNU General Public License Version 2 as published by the
# Free Software Foundation.
# 
# nesC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with nesC; see the file COPYING.  If not, write to
# the Free Software Foundation, 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

true;

sub gen() {
    my ($classname, @spec) = @_;

    require migdecode;
    &decode(@spec);

    &usage("no classname name specified") if !defined($java_classname);

    $java_extends = "net.tinyos.message.Message" if !defined($java_extends);
    if ($java_classname =~ /(.*)\.([^.]*)$/) {
	$package = $1;
	$java_classname = $2;
    }
    else {
	print STDERR "no package specification in class name $java_classname\n";
	exit 2;
    }

    print "/**\n";
    print " * This class is automatically generated by mig. DO NOT EDIT THIS FILE.\n";
    print " * This class implements a Java interface to the '$java_classname'\n";
    print " * message type.\n";
    print " */\n\n";

    print "package $package;\n\n";

    print "public class $java_classname extends $java_extends {\n\n";

    print "    /** The default size of this message type in bytes. */\n";
    print "    public static final int DEFAULT_MESSAGE_SIZE = $size;\n\n";

    print "    /** The Active Message type associated with this message. */\n";
    print "    public static final int AM_TYPE = $amtype;\n\n";

    print "    /** Create a new $java_classname of size $size. */\n";
    print "    public $java_classname() {\n";
    print "        super(DEFAULT_MESSAGE_SIZE);\n";
    print "    }\n\n";

    print "    /** Create a new $java_classname of the given data_length. */\n";
    print "    public $java_classname(int data_length) {\n";
    print "        super(data_length);\n";
    print "    }\n\n";

    print "    /**\n";
    print "     * Create a new $java_classname with the given data_length\n";
    print "     * and base offset.\n";
    print "     */\n";
    print "    public $java_classname(int data_length, int base_offset) {\n";
    print "        super(data_length, base_offset);\n";
    print "    }\n\n";

    print "    /**\n";
    print "     * Create a new $java_classname using the given byte array\n";
    print "     * as backing store.\n";
    print "     */\n";
    print "    public $java_classname(byte[] data) {\n";
    print "        super(data);\n";
    print "    }\n\n";

    print "    /**\n";
    print "     * Create a new $java_classname using the given byte array\n";
    print "     * as backing store, with the given base offset.\n";
    print "     */\n";
    print "    public $java_classname(byte[] data, int base_offset) {\n";
    print "        super(data, base_offset);\n";
    print "    }\n\n";

    print "    /**\n";
    print "     * Create a new $java_classname using the given byte array\n";
    print "     * as backing store, with the given base offset and data length.\n";
    print "     */\n";
    print "    public $java_classname(byte[] data, int base_offset, int data_length) {\n";
    print "        super(data, base_offset, data_length);\n";
    print "    }\n\n";

    print "    /**\n";
    print "     * Create a new $java_classname embedded in the given message\n";
    print "     * at the given base offset.\n";
    print "     */\n";
    print "    public $java_classname(net.tinyos.message.Message msg, int base_offset) {\n";
    print "        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);\n";
    print "    }\n\n";

    print "    /**\n";
    print "     * Create a new $java_classname embedded in the given message\n";
    print "     * at the given base offset and length.\n";
    print "     */\n";
    print "    public $java_classname(net.tinyos.message.Message msg, int base_offset, int data_length) {\n";
    print "        super(msg, base_offset, data_length);\n";
    print "    }\n\n";

# XXX MDW: Deprecated
#    print "    $java_classname(net.tinyos.message.ByteArray packet, int size) {\n";
#    print "        this(size);\n";
#    print "        dataSet(packet);\n";
#    print "    }\n\n";
#
#    print "    $java_classname(net.tinyos.message.ByteArray packet) {\n";
#    print "        this(packet, $size);\n";
#    print "    }\n\n";

    print "    /** Return the Active Message type of this message (-1 if unknown). */\n";
    print "    public int amType() {\n";
    print "        return AM_TYPE;\n";
    print "    }\n\n";

    print "    /**\n";
    print "    /* Return a String representation of this message. Includes the\n";
    print "     * message type name and the non-indexed field values.\n";
    print "     */\n";
    print "    public String toString() {\n";
    print "      String s = \"Message <$java_classname> \";\n";
    for (@fields) {
	($field, $type, $bitlength, $offset, $amax, $abitsize, $aoffset) = @{$_};
	$javafield = $field;
	$javafield =~ s/\./_/g;
	if (!@$amax) {
          print "      s += \"[$field=0x\"+Long.toHexString(get\u$javafield())+\"] \";\n";
	}
    }
    print "      return s;\n";
    print "    }\n\n";

    print "    // Message-type-specific access methods appear below.\n\n";
    for (@fields) {
	($field, $type, $bitlength, $offset, $amax, $abitsize, $aoffset) = @{$_};

	$javafield = $field;
	$javafield =~ s/\./_/g;
	
	($javatype, $java_access) = &javabasetype($type, $bitlength);

	$index = 0;
	@args = map { $index++; "int index$index" } @{$amax};
	$argspec = join(", ", @args);

	$index = 0;
	@passargs = map { $index++; "index$index" } @{$amax};
	$passargs = join(", ", @passargs);

	print "    /////////////////////////////////////////////////////////\n";
	print "    // Accessor methods for field: $field\n";
	print "    //   Field type: $javatype\n";
	print "    //   Offset (bits): $offset\n";
	print "    //   Size (bits): $bitlength\n";
	print "    /////////////////////////////////////////////////////////\n\n";
	print "    /**\n";
	print "     * Return the offset, in bits, of the field: $field\n";
	print "     * in this message.\n";
	print "     */\n";
	print "    public static int offset\u$javafield($argspec) {\n";
	printoffset($base + $offset, $amax, $abitsize, $aoffset);
	print "        return offset;\n";
	print "    }\n\n";

	print "    /**\n";
	print "     * Return the value (as a $javatype) of the field: $field\n";
	print "     */\n";
	print "    public $javatype get\u$javafield($argspec) {\n";
	print "        return ($javatype)get$java_access(offset\u$javafield($passargs), $bitlength);\n";
	print "    }\n\n";

	print "    /**\n";
	print "     * Set the value of the field: $field\n";
	print "     */\n";
	push @args, "$javatype value";
	$argspec = join(", ", @args);
	print "    public void set\u$javafield($argspec) {\n";
	print "        set$java_access(offset\u$javafield($passargs), $bitlength, value);\n";
	print "    }\n\n";

        # For arrays
	if (@$amax) {
	  print "    /**\n";
	  print "     * Return the size, in bits, of each element of the array field: $field\n";
	  print "     */\n";
	  print "    public static int elementSize\u$javafield() {\n";
	  print "        return $$abitsize[0];\n";
	  print "    }\n\n";

	  if ($$amax[0] != 0) {
  	    print "    /**\n";
	    print "     * Return the number of elements in the array field: $field\n";
	    print "     */\n";
	    print "    public static int numElements\u$javafield() {\n";
	    print "        return $$amax[0];\n";
	    print "    }\n\n";
	  }

	  if (@$amax==1 && $bitlength == 8) {
	      print "    /**\n";
	      print "     * Fill in the $field array with a String\n";
	      print "     */\n";
	      print "    public void set\u$javafield(String s) { \n";
	      if ($amax[0] != 0) {
                print "         int len = Math.min(s.length(), $$amax[0]-1);\n";
	      } else {
                print "         int len = s.length();\n";
	      }
	      print "         int i;\n";
	      print "         for (i = 0; i < len; i++) {\n";
	      print "             set\u$javafield(i, ($javatype)s.charAt(i));\n";
              print "         }\n";
	      print "         set\u$javafield(i, ($javatype)0); //null terminate\n";
	      print "    }\n\n";

	      if ($amax[0] != 0) {
  	        print "    /**\n";
 	        print "     * Read the $field array as a String\n";
	        print "     */\n";
	        print "    public String get\u$javafield() { \n";
                print "         char carr[] = new char[$$amax[0]];\n";
	        print "         int i;\n";
	        print "         for (i = 0; i < $$amax[0]; i++) {\n";
	        print "             if ((char)get\u$javafield(i) == (char)0) break;\n";
	        print "             carr[i] = (char)get\u$javafield(i);\n";
                print "         }\n";
                print "         return new String(carr,0,i-1);\n";
	        print "    }\n\n";
	      }
	  }

  	  print "    /**\n";
	  print "     * Return the size, in bits, of the field: $field\n";
	  print "     */\n";
	  print "    public static int size\u$javafield() {\n";
	  print "        return $$abitsize[0] * $$amax[0];\n";
	  print "    }\n\n";

	} else {
	  # For non-arrays
  	  print "    /**\n";
	  print "     * Return the size, in bits, of the field: $field\n";
	  print "     */\n";
	  print "    public static int size\u$javafield() {\n";
	  print "        return $bitlength;\n";
	  print "    }\n\n";
	}
    }

    print "}\n";
}

sub javabasetype()
{
    my ($basetype, $bitlength) = @_;
    my $jtype, $acc;

    return ("float", "FloatElement")
	if ($basetype eq "F" || $basetype eq "D" || $basetype eq "LD");

    # Pick the java type whose range is closest to the corresponding C type
    if ($basetype eq "U") {
	$acc = "UIntElement";
	return ("byte", $acc) if $bitlength < 8;
	return ("char", $acc) if $bitlength <= 16;
	return ("int", $acc) if $bitlength < 32;
	return ("long", $acc);
    }
    if ($basetype eq "I") {
	$acc = "SIntElement";
	return ("byte", $acc) if $bitlength <= 8;
	return ("short", $acc) if $bitlength <= 16;
	return ("int", $acc) if $bitlength <= 32;
	return ("long", $acc);
    }

    return (0, 0);
}

sub printoffset()
{
    my ($offset, $max, $bitsize, $aoffset) = @_;

    print "        int offset = $offset;\n";
    for ($i = 1; $i <= @$max; $i++) {
	# check index bounds. 0-sized arrays don't get an upper-bound check
	# (they represent variable size arrays. Normally they should only
	# occur as the first-dimension of the last element of the structure)
	if ($$max[$i - 1] != 0) {
	    print "        if (index$i < 0 || index$i >= $$max[$i - 1]) throw new ArrayIndexOutOfBoundsException();\n";
	}
	else {
	    print "        if (index$i < 0) throw new ArrayIndexOutOfBoundsException();\n";
	}
	print "        offset += $$aoffset[$i - 1] + index$i * $$bitsize[$i - 1];\n";
    }
}
