package eu.numberfour.asciispec.processors;

/**
 * Registration class for the {@link InlineRepoLinkExtension} processor.
 *
 * If you rename or move this class, do not forget to update the
 * META-INF/services/org.asciidoctor.extension.spi.ExtensionRegistry file!
 */
public class InlineRepoLinkExtension extends ProcessorExtension {
	@Override
	protected void register(JavaExtensionRegistry registry) {
		registry.preprocessor(InlineRepoLinkProcessor.class);
	}
}
