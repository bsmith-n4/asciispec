/**
 * Copyright (c) 2016 NumberFour AG.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   NumberFour AG - Initial API and implementation
 */
package eu.numberfour.asciispec.processors

import eu.numberfour.asciispec.AsciidoctorTest
import eu.numberfour.asciispec.sourceindex.AmbiguousPQNExcpetion
import eu.numberfour.asciispec.sourceindex.NotInSourceIndexExcpetion
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.ExpectedException

/**
 * Test cases for {@link InlineWikiLinkProcessor}.
 */
class SourceLinkProcessorTest extends AsciidoctorTest {

	@Rule
	public final ExpectedException exception = ExpectedException.none();

	@Before
	public def void registerExtensions() {
		new SourceLinkExtension().register(doc);
	}


	private def getConfig() '''

			«configA»
			«configB»
		'''

	private def getConfigA() '''
			:linkattrs:
			:gen_adoc_dir: src/test/resources/data/docu/gen_adoc

		'''

	private def getConfigB() '''
			:srclnk_repo_def: stdlib_api;Standard lib API;https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/{CMS_PATH}#L{LINE_NO}

		'''

	private def getConfigC() '''
			:srclnk_repo_def: stdlib_api2;Standard lib API;https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/{CMS_PATH}#L{LINE_NO}

		'''

	@Test
	public def void testMissingConfiguration() {
    		convertStringAndAssertErrorContains(
			'''
			<div class="paragraph">
			<p>This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]</p>
			</div>''',
			'''

			This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]
			''',
			"asciispec  : ERROR: line 2: Missing config variable 'gen_adoc_dir'."
		);
	}

	@Test
	public def void testMissingConfigurationA() {
    		convertStringAndAssertErrorContains(
			'''
			<div class="paragraph">
			<p>This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]</p>
			</div>''',
			'''
			«configA»

			This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]
			''',
			"asciispec  : ERROR: line 5: Missing config variable 'srclnk_repo_def'."
		);
	}

	@Test
	public def void testMissingConfigurationB() {
    		convertStringAndAssertErrorContains(
			'''
			<div class="paragraph">
			<p>This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]</p>
			</div>''',
			'''
			«configB»

			This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]
			''',
			"asciispec  : ERROR: line 4: Missing config variable 'gen_adoc_dir'."
		);
	}

	@Test
	public def void testMissingRepository() {
    		convertStringAndAssertErrorContains(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DurationFormats:TimeSpanPatternFormat@getStartWithQuantityFormat" target="_blank">My SRC link [Error: Missing config for repository 'stdlib_api']</a></p>
			</div>''',
			'''
			«configA»
			«configC»

			This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]
			''',
			"asciispec  : ERROR: Missing srclnk repository configuration found for : 'stdlib_api'."
		);
	}

	@Test
	public def void testPassMacro1() {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/StructuredText.n4jsd#L23" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/StructuredText:StructuredText#onAction" target="_blank">protected onAction(failed: Array&lt;Iterable3&lt;Constraint,ConstraintValidation,string&gt;&gt;): void</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:++StructuredText#onAction++[++protected onAction(failed: Array<Iterable3<Constraint,ConstraintValidation,string>>): void++]
			'''
		);
	}

	@Test
	public def void testPassMacro2() {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/StructuredText.n4jsd#L23" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/StructuredText:StructuredText#onAction" target="_blank">protected onAction(failed: Array&lt;Iterable3&lt;~i~Constraint,[ConstraintValidation],string&gt;&gt;): void</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:++StructuredText#onAction++[++protected onAction(failed: Array<Iterable3<~i~Constraint,[ConstraintValidation],string>>): void++]
			'''
		);
	}

	@Test
	public def void testMonospaceMacro() {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/StructuredText.n4jsd#L55" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/StructuredText:StructuredText@fromN4ML" target="_blank"><code>protected fromN4ML(failed: Array&lt;Iterable3&lt;Constraint,ConstraintValidation,string&gt;&gt;): void</code></a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:StructuredText@fromN4ML[``protected fromN4ML(failed: Array<Iterable3<Constraint,ConstraintValidation,string>>): void``]
			'''
		);
	}

	@Test
	public def void testMonospaceAndPassMacros() {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/StructuredText.n4jsd#L55" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/StructuredText:StructuredText@fromN4ML" target="_blank"><code>protected fromN4ML(failed: Array&lt;Iterable3&lt;Constraint,ConstraintValidation,string&gt;&gt;): void</code></a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:++StructuredText@fromN4ML++[``++protected fromN4ML(failed: Array<Iterable3<Constraint,ConstraintValidation,string>>): void++``]
			'''
		);
	}

	@Test
	public def void testSimpleEntry1() {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DurationFormats.n4jsd#L92" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DurationFormats:TimeSpanPatternFormat@getStartWithQuantityFormat" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:getStartWithQuantityFormat[My SRC link]
			'''
		);
	}

	@Test
	public def parseSimpleEntry2() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry3() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry4() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry5() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:format/DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry6() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:n4/format/DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry7() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry8() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry9() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry10() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseSimpleEntry11() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.stdlib.format.api/src/n4js/n4/format/DateTimeFormat.n4jsd#L18" title="stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:stdlib_api:packages:eu.numberfour.stdlib.format.api:src/n4js/n4/format/DateTimeFormat:DateTimeFormat@withStyle[My SRC link]
			''');
	}

	@Test
	public def parseModuleFunction1() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertAndAssert(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="https://github.numberfour.eu/NumberFour/stdlib_api/blob/master/packages/eu.numberfour.n4js.base.api/src/n4js/n4/lang/IterableExt.n4jsd#L151" title="stdlib_api:packages:eu.numberfour.n4js.base.api:src/n4js/n4/lang/IterableExt:first" target="_blank">My SRC link</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:++stdlib_api:packages:eu.numberfour.n4js.base.api:src/n4js/n4/lang/IterableExt:first++[My SRC link]
			''');
	}

	@Test
	public def parseUnknownEntry() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertStringAndAssertErrorContains(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="" title="DateXY@withStyle" target="_blank">My SRC link [Error: PQN not found]</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:DateXY@withStyle[My SRC link]
			''',
			"asciispec  : ERROR: srclnk PQN not found: 'DateXY@withStyle'.");
	}

	@Test
	public def parseAmbiguousPQN1() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertStringAndAssertErrorContains(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="" title="withPattern" target="_blank">My SRC link [Error: Ambiguous PQN]</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:withPattern[My SRC link]
			''',
			"asciispec  : ERROR: srclnk PQN is ambiguous: 'withPattern'.");
	}

	@Test
	public def parseAmbiguousPQN2() throws NotInSourceIndexExcpetion, AmbiguousPQNExcpetion {
		convertStringAndAssertErrorContains(
			'''
			<div class="paragraph">
			<p>This is a source link: <a href="" title="@withPattern" target="_blank">My SRC link [Error: Ambiguous PQN]</a></p>
			</div>''',
			'''
			«config»

			This is a source link: srclnk:@withPattern[My SRC link]
			''',
			"asciispec  : ERROR: srclnk PQN is ambiguous: '@withPattern'.");
	}
}